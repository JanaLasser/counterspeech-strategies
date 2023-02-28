import pandas as pd
from pathlib import Path
import sys
from torch.utils.data import DataLoader, Dataset
from transformers import XLMRobertaForSequenceClassification
from transformers import XLMRobertaTokenizerFast
from transformers import TrainingArguments
from transformers import Trainer
from scipy.special import softmax
from os.path import join
from torch import cuda
import torch as th
import numpy as np

test = False

model_src = "../models/foreign"
model = XLMRobertaForSequenceClassification.from_pretrained(model_src)

tokenizer_src = "../models/twitter-xlm-roberta-base"
tokenizer = XLMRobertaTokenizerFast.from_pretrained(tokenizer_src)


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
    
fname = "flat_trees.csv.gzip"
data_src = "../data/"

cols = ["tweet_id", "text"]
if test:
    df = pd.read_csv(Path(data_src, fname), nrows=10, compression="gzip", usecols=cols)
else:
    df = pd.read_csv(Path(data_src, fname), compression="gzip", usecols=cols)

if test:
    batch_size = 10
else:
    batch_size = 4096

inference_set = InferenceDataset(df, tokenizer, max_token_len=100)
inference_params = {'batch_size': batch_size, 'shuffle': False}
inference_loader = DataLoader(inference_set, **inference_params)

                     
training_args = TrainingArguments(
    "test-trainer",
    per_device_train_batch_size = 16,
    per_device_eval_batch_size = 16,
    num_train_epochs = 5,
    learning_rate = 2e-5,
    weight_decay = 0.01,
    evaluation_strategy = "epoch"
)

trainer = Trainer(
        model,
        training_args,
        tokenizer = tokenizer,
)

device = 'cuda' if cuda.is_available() else 'cpu'
print("device: {}".format(device))

raw_pred, _, _ = trainer.prediction_loop(inference_loader, description="prediction")
foreign = np.argmax(softmax(raw_pred), axis=1)
df['foreign'] = foreign

if test:
    print(df['foreign'])
else:
    fname = "flat_trees_inferred_foreign.csv.gzip"
    df.to_csv(Path(data_src, "inference", fname), index=False, compression="gzip")