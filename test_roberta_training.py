from transformers import AutoTokenizer
from transformers import AutoModelForSequenceClassification, Trainer, TrainingArguments
import torch
import numpy as np
from sklearn.metrics import classification_report
from datasets import load_metric

from torch import cuda
from os.path import join
import sys

EPOCHS = int(sys.argv[1])

try:
    TEST = sys.argv[1]
    if TEST == 'test':
        TEST = True
    else:
        print('argument {} not recognized!'.format(TEST))
except IndexError:
    TEST = False

LR = 2e-5
BATCH_SIZE = 32
MODEL = "models/twitter-xlm-roberta-base" 

if TEST:  
    MAX_TRAINING_EXAMPLES = 100 
    MAX_TEST_EXAMPLES = int(MAX_TRAINING_EXAMPLES/2)
    MAX_VAL_EXAMPLES = int(MAX_TEST_EXAMPLES/2)
else:
    MAX_TRAINING_EXAMPLES = -1
    MAX_TEST_EXAMPLES = -1
    MAX_VAL_EXAMPLES = -1

dataset_dict = {}
for i in ['train','val','test']:
    dataset_dict[i] = {}
    for j in ['text','labels']:
        dataset_dict[i][j] = open(f"data/traindata/{i}_{j}.txt")\
            .read().strip('\n').split('\n')
        if j == 'labels':
            dataset_dict[i][j] = [int(x) for x in dataset_dict[i][j]]

if MAX_TRAINING_EXAMPLES > 0:
    dataset_dict['train']['text'] = \
        dataset_dict['train']['text'][:MAX_TRAINING_EXAMPLES]
    dataset_dict['train']['labels'] = \
        dataset_dict['train']['labels'][:MAX_TRAINING_EXAMPLES]
    
if MAX_TEST_EXAMPLES > 0:
    dataset_dict['test']['text'] = \
        dataset_dict['test']['text'][:MAX_TEST_EXAMPLES]
    dataset_dict['test']['labels'] = \
        dataset_dict['test']['labels'][:MAX_TEST_EXAMPLES]

if MAX_VAL_EXAMPLES > 0:
    dataset_dict['val']['text'] = \
        dataset_dict['val']['text'][:MAX_VAL_EXAMPLES]
    dataset_dict['val']['labels'] = \
        dataset_dict['val']['labels'][:MAX_VAL_EXAMPLES]
    
tokenizer = AutoTokenizer.from_pretrained(MODEL, use_fast=True)
train_encodings = tokenizer(dataset_dict['train']['text'], truncation=True, padding=True)
val_encodings = tokenizer(dataset_dict['val']['text'], truncation=True, padding=True)
test_encodings = tokenizer(dataset_dict['test']['text'], truncation=True, padding=True)

class MyDataset(torch.utils.data.Dataset):
    def __init__(self, encodings, labels):
        self.encodings = encodings
        self.labels = labels

    def __getitem__(self, idx):
        item = {key: torch.tensor(val[idx]) for key, val in self.encodings.items()}
        item['labels'] = torch.tensor(self.labels[idx])
        return item

    def __len__(self):
        return len(self.labels)

train_dataset = MyDataset(train_encodings, dataset_dict['train']['labels'])
val_dataset = MyDataset(val_encodings, dataset_dict['val']['labels'])
test_dataset = MyDataset(test_encodings, dataset_dict['test']['labels'])

training_args = TrainingArguments(
    output_dir='./results',                   # output directory
    num_train_epochs=EPOCHS,                  # total number of training epochs
    per_device_train_batch_size=BATCH_SIZE,   # batch size per device during training
    per_device_eval_batch_size=BATCH_SIZE,    # batch size for evaluation
    warmup_steps=100,                         # number of warmup steps for learning rate scheduler
    weight_decay=0.01,                        # strength of weight decay
    logging_dir='./logs',                     # directory for storing logs
    logging_steps=10,                         # when to print log
    load_best_model_at_end=True,              # load or not best model at the end
    save_strategy='no',
    eval_accumulation_steps=1,
)

num_labels = len(set(dataset_dict["train"]["labels"]))
model = AutoModelForSequenceClassification.from_pretrained(MODEL, num_labels=num_labels)

metric = load_metric("f1")
def compute_metrics(eval_preds):
    logits, labels = eval_preds
    predictions = np.argmax(logits, axis=-1)
    return metric.compute(predictions=predictions, references=labels)

trainer = Trainer(
        model=model,
        args=training_args,
        #device = device,
        train_dataset = train_dataset,
        eval_dataset = val_dataset,
        #data_collator = data_collator,
        #tokenizer = tokenizer,
        compute_metrics = compute_metrics
)

trainer.train()
trainer.save_model("./results/best_model") # save best model

test_preds_raw, test_labels , _ = trainer.predict(test_dataset)
test_preds = np.argmax(test_preds_raw, axis=-1)
print(classification_report(test_labels, test_preds, digits=3))