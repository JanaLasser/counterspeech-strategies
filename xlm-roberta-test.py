from datasets import load_dataset
from datasets import load_metric

from transformers import AutoTokenizer, DataCollatorWithPadding
from transformers import AutoModelForSequenceClassification
from transformers import Trainer, TrainingArguments

import numpy as np
from torch import cuda

checkpoint = "models/xlm-roberta-base"

def tokenize_function(example):
    return tokenizer(example["sentence1"], example["sentence2"], truncation=True)

def compute_metrics(eval_preds):
    logits, labels = eval_preds
    predictions = np.argmax(logits, axis=-1)
    return metric.compute(predictions=predictions, references=labels)

raw_datasets = load_dataset("glue", "mrpc")
tokenizer = AutoTokenizer.from_pretrained(checkpoint)
tokenized_datasets = raw_datasets.map(tokenize_function, batched=True)
small_train_dataset = tokenized_datasets["train"].shuffle(seed=42).select(range(1000))
small_eval_dataset = tokenized_datasets["test"].shuffle(seed=42).select(range(1000))
full_train_dataset = tokenized_datasets["train"]
full_eval_dataset = tokenized_datasets["test"]

data_collator = DataCollatorWithPadding(tokenizer)

model = AutoModelForSequenceClassification.from_pretrained(checkpoint, num_labels=2)

training_args = TrainingArguments(
    "test-trainer",
    per_device_train_batch_size = 16,
    per_device_eval_batch_size = 16,
    num_train_epochs = 5,
    learning_rate = 2e-5,
    weight_decay = 0.01,
    evaluation_strategy = "epoch"
)

metric = load_metric("glue", "mrpc")

device = 'cuda' if cuda.is_available() else 'cpu'
print('device: {}'.format(device))

trainer = Trainer(
        model,
        training_args,
        #device = device,
        train_dataset = full_train_dataset,
        eval_dataset = full_eval_dataset,
        data_collator = data_collator,
        tokenizer = tokenizer,
        compute_metrics = compute_metrics
)

trainer.train()