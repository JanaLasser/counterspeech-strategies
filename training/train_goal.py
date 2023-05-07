from transformers import AutoTokenizer, EarlyStoppingCallback
from transformers import AutoModelForSequenceClassification
from transformers import Trainer, TrainingArguments
import torch
import numpy as np
import pandas as pd
from sklearn.metrics import classification_report
from datasets import load_metric

from torch import cuda
from os.path import join
import sys

from training_utils import MyDataset, compute_metrics

MODEL = sys.argv[1]
MODEL_NAME = MODEL.split("/")[-1]
MODEL_TYPE = MODEL_NAME.split("_")[0]
EPOCHS = int(sys.argv[2])
BATCH_SIZE = int(sys.argv[3])
EVAL_STEPS = int(sys.argv[4])
DATA_BATCH = sys.argv[5]
DATA_SPLITS = int(sys.argv[6])

try:
    SAVE_MODEL = sys.argv[7]
    if SAVE_MODEL == "save":
        SAVE_MODEL = True
    else:
        print(f"unknown argument for SAVE_MODEL: {SAVE_MODEL}")
        SAVE_MODEL=False
except IndexError:
    SAVE_MODEL = False

LR = 2e-5
 
DATA_SRC = "../data/traindata/"
DATA_NAME = f"{DATA_BATCH}"
TOKENIZER = f"../models/{MODEL_TYPE}"

MAX_TRAINING_EXAMPLES = -1
MAX_TEST_EXAMPLES = -1
MAX_VAL_EXAMPLES = -1

sample_numbers = [MAX_TRAINING_EXAMPLES, MAX_TEST_EXAMPLES, MAX_VAL_EXAMPLES]
datatypes = ['train','eval','test']
splits = [1, 2, 3, 4, 5]
dataset_dict = {i:{} for i in splits}

for j in splits:
    for i in datatypes:
        dataset_dict[j][i] = {}
        data = pd.read_csv(
            join(DATA_SRC, DATA_NAME + f"_{i}_{j}.csv"),
            usecols=["text", "label"],
            dtype={"text":str, "label":int},
            delimiter=";"
        )
        dataset_dict[j][i]["text"] = list(data["text"].values)
        dataset_dict[j][i]["labels"] = list(data["label"].values)

for split in splits[0:DATA_SPLITS]:
            
    tokenizer = AutoTokenizer.from_pretrained(TOKENIZER, use_fast=True)
    train_encodings = tokenizer(dataset_dict[split]['train']['text'],
                truncation=True, padding=True, max_length=180)
    eval_encodings = tokenizer(dataset_dict[split]['eval']['text'],
                truncation=True, padding=True, max_length=180)
    test_encodings = tokenizer(dataset_dict[split]['test']['text'],
                truncation=True, padding=True, max_length=180)

    train_dataset = MyDataset(train_encodings, dataset_dict[split]['train']['labels'])
    eval_dataset = MyDataset(eval_encodings, dataset_dict[split]['eval']['labels'])
    test_dataset = MyDataset(test_encodings, dataset_dict[split]['test']['labels'])

    training_args = TrainingArguments(
        output_dir='./results',                   # output directory
        num_train_epochs=EPOCHS,                  # total number of training epochs
        per_device_train_batch_size=BATCH_SIZE,   # batch size per device during training
        per_device_eval_batch_size=BATCH_SIZE,    # batch size for evaluation
        warmup_steps=100,                         # number of warmup steps for learning rate scheduler
        weight_decay=0.0025,                        # strength of weight decay
        logging_dir='./logs',                     # directory for storing logs
        logging_steps=10,                         # when to print log
        load_best_model_at_end=True,              # load or not best model at the end
        save_strategy="steps",
        eval_accumulation_steps=1,
        metric_for_best_model="eval_loss",
        evaluation_strategy="steps",
        eval_steps=EVAL_STEPS,
        seed=42
    )

    num_labels = len(set(dataset_dict[split]["train"]["labels"]))
    model = AutoModelForSequenceClassification.from_pretrained(MODEL, num_labels=num_labels)
    
    trainer = Trainer(
            model=model,
            args=training_args,
            train_dataset = train_dataset,
            eval_dataset = eval_dataset,
            compute_metrics = compute_metrics,
            callbacks = [EarlyStoppingCallback(5, 0)]
    )

    trainer.train()
    if SAVE_MODEL:
        trainer.save_model(f"../best_models/model-{MODEL_NAME}_data-{DATA_NAME}_split-{split}")

    test_preds_raw, test_labels , _ = trainer.predict(test_dataset)
    test_preds = np.argmax(test_preds_raw, axis=-1)
    report = classification_report(test_labels, test_preds, digits=3, output_dict=True)
    print(classification_report(test_labels, test_preds, digits=3))
    df = pd.DataFrame(report).transpose()
    
    fname = f"report_model-{MODEL_NAME}_data-{DATA_NAME}_epochs-{EPOCHS}_bs-{BATCH_SIZE}_split-{split}.csv"
    df.to_csv(join("../data/inference/reports_goal/", fname), index=False)
    
    