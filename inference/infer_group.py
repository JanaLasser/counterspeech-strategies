import pandas as pd
from os.path import join
import sys
from torch.utils.data import DataLoader, Dataset
from transformers import AutoModelForSequenceClassification, AutoTokenizer
from transformers import TrainingArguments
from transformers import Trainer
from scipy.special import softmax
from os.path import join
from torch import cuda
import torch as th
import numpy as np

MODEL_PATH = sys.argv[1]
MODEL_NAME = MODEL_PATH.split("/")[-1].split("_data")[0].replace("model-", "")
MODEL_TYPE = MODEL_NAME.split("_")[0]
MODEL_DATA_NAME = MODEL_PATH.split("data-")[1].split("_split")[0]
DATASET_PATH = sys.argv[2]
DATASET_NAME = DATASET_PATH.split("/")[-1].split(".")[0]
NUM_LABELS = int(sys.argv[3])
TOKENIZER_PATH = f"../models/{MODEL_TYPE}"

if NUM_LABELS == 5:
    group_dict = {
        0:"in",
        1:"out",
        2:"both",
        3:"neutral",
        4:"unint",
        }
elif NUM_LABELS == 3:
    group_dict = {
        0:"in_both",
        1:"out",
        2:"neutral_unint"
    }
elif NUM_LABELS == 2:
    group_dict = {
        0:"not_out",
        1:"out",
    }
else:
    print(f"unknown number of labels {NUM_LABLES} - exiting")
    sys.exit()

class InferenceDataset(Dataset):
    def __init__(self, data, tokenizer, max_token_len):
        self.data = data
        self.tokenizer = tokenizer
        self.max_token_len = max_token_len

    def __len__(self):
        return len(self.data)

    def __getitem__(self, index):
        data_row = self.data.iloc[index]
        text = data_row.text
        encoding = self.tokenizer.encode_plus(
            text=text,
            add_special_tokens=True,
            max_length=self.max_token_len,
            return_token_type_ids=True,
            padding="max_length",
            truncation=True,
            return_attention_mask=True)

        return dict(
            input_ids=th.tensor(encoding["input_ids"], dtype=th.long),
            attention_mask=th.tensor(encoding["attention_mask"], dtype=th.long),
            token_type_ids=th.tensor(encoding["token_type_ids"], dtype=th.long)
        )

BATCH_SIZE = 8192

if DATASET_PATH.endswith(".gzip"):
    cols = ["tweet_id", "text"]
    df = pd.read_csv(DATASET_PATH, usecols=cols, compression="gzip")
else:
    cols = ["tweet_id", "text", "label"]
    df = pd.read_csv(DATASET_PATH, usecols=cols, delimiter=";")
    
training_args = TrainingArguments(
    "test-trainer",
    per_device_train_batch_size = 16,
    per_device_eval_batch_size = 16,
    num_train_epochs = 5,
    learning_rate = 2e-5,
    weight_decay = 0.01,
    evaluation_strategy = "epoch"
)

model = AutoModelForSequenceClassification.from_pretrained(MODEL_PATH)
tokenizer = AutoTokenizer.from_pretrained(TOKENIZER_PATH, use_fast=True)

inference_set = InferenceDataset(df, tokenizer, max_token_len=100)
inference_params = {'batch_size': BATCH_SIZE, 'shuffle': False}
inference_loader = DataLoader(inference_set, **inference_params)

trainer = Trainer(
        model,
        training_args,
        tokenizer = tokenizer,
)

raw_pred, _, _ = trainer.prediction_loop(
    inference_loader, 
    description="prediction"
)
norm_pred = softmax(raw_pred, axis=1)
group = np.argmax(norm_pred, axis=1)

df[f'group'] = group
for label in group_dict.keys():
    df[group_dict[label]] = norm_pred[0:, label]

condensation_dict = {2:"_condensed", 3:"_halfcondensed", 5:""}
fname = "inferred_group{}_{}.csv"\
    .format(condensation_dict[NUM_LABELS], DATASET_NAME)
df.to_csv(fname, index=False, sep=";")