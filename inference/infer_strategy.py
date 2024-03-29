import pandas as pd
from os.path import join
import sys
from torch.utils.data import DataLoader, Dataset
#from transformers import XLMRobertaForSequenceClassification
#from transformers import XLMRobertaTokenizerFast
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
DST = "../data/inference/"

if NUM_LABELS == 5:
    strategy_dict = {
        0:"construct",
        1:"opin",
        2:"sarc",
        3:"leave_fact",
        4:"other_new",
    }
elif NUM_LABELS == 7:
    strategy_dict = {
        0:"info",
        1:"opin",
        2:"construct",
        3:"inconsist",
        4:"sarc",
        5:"insult",
        6:"other_new",
    }
elif NUM_LABELS == 13:
    strategy_dict = {
        "info":0,
        "opin":1,
        "quest":2,
        "conseq":3,
        "correct":4,
        "inconsist":5,
        "sarc":6,
        "insult-pers":7,
        "insult-ism":8,
        "insult-polit":9,
        "insult-inst":10,
        "other":11,
        "unint":12
    }
else:
    print(f"unknown number of labels {NUM_LABLES} - exiting")
    sys.exit()

print(MODEL_NAME)
print(DATASET_NAME)

test = False

model = AutoModelForSequenceClassification.from_pretrained(MODEL_PATH)
tokenizer = AutoTokenizer.from_pretrained(TOKENIZER_PATH, use_fast=True)

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

        return dict(input_ids=th.tensor(encoding["input_ids"], dtype=th.long),
                    attention_mask=th.tensor(encoding["attention_mask"], dtype=th.long),
                    token_type_ids=th.tensor(encoding["token_type_ids"], dtype=th.long))
    
    
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
strategies = np.argmax(norm_pred, axis=1)
df['strategy'] = strategies
for label in strategy_dict.keys():
    df[strategy_dict[label]] = norm_pred[0:, label]

condensation_dict = {5:"_condensed", 7:"_halfcondensed", 13:""}
fname = "inferred_strategy{}_{}.csv"\
    .format(condensation_dict[NUM_LABELS], DATASET_NAME)
df.to_csv(join(DST, fname), index=False, sep=";")