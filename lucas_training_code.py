import numpy as np
import pandas as pd
from tqdm import tqdm
from collections import OrderedDict
import matplotlib.pyplot as plt
import pickle
from sklearn.metrics import f1_score
from sklearn.feature_extraction.text import TfidfVectorizer
import numpy as np, scipy.stats as st
import statsmodels.stats.api as sms
import itertools
import gc
from sklearn.metrics import classification_report
import transformers

import torch.nn.functional as F
import torch as th
from torch.utils.data import Dataset, DataLoader

from tqdm import tqdm

from robertaTwitterTrain_woSurprise import VENTEmotionTagger as ROBERTA

# unfortunately this hack is necessary to delete flags
from absl import flags

for name in list(flags.FLAGS):
  delattr(flags.FLAGS, name)

from BERTEmoji_woSurprise import VENTEmotionTagger as BERT

for name in list(flags.FLAGS):
  delattr(flags.FLAGS, name)


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
        labels = data_row["label"]
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
                    token_type_ids=th.tensor(encoding["token_type_ids"], dtype=th.long),
                    labels=th.tensor(labels, dtype=th.long))

def add_f1s(f1_scores, avg, f1_dict):
    f1_dict["Affection"].append(f1_scores[0])
    f1_dict["Anger"].append(f1_scores[1])
    f1_dict["Fear"].append(f1_scores[2])
    f1_dict["Happiness"].append(f1_scores[3])
    f1_dict["Sadness"].append(f1_scores[4])
    f1_dict["Average"].append(avg)
    return f1_dict

def calculate_intervalls(f1_dict):
    for emotion in ['Affection', 'Anger','Fear','Happiness','Sadness','Average']:
        #interval = st.t.interval(0.95, len(f1_dict[emotion]) - 1, loc=np.mean(f1_dict[emotion]),
        #                         scale=st.sem(f1_dict[emotion]))
        interval = sms.DescrStatsW(f1_dict[emotion]).tconfint_mean()
        m = np.mean(f1_dict[emotion])
        print("{}: {} +/- {}".format(emotion, m, m - interval[1]))

def predict_pt(model, tokenizer, df, device="cuda"):
    # convert to dataloader
    inference_set = InferenceDataset(df, tokenizer, max_token_len=128)

    inference_params = {'batch_size': 512, 'shuffle': False, 'num_workers': 4}

    inference_loader = DataLoader(inference_set, **inference_params)

    # append probabilities
    fin_probs = []

    with th.no_grad():
        for _, data in tqdm(enumerate(inference_loader, 0), total=len(inference_loader)):
            _, outputs = model(input_ids=data['input_ids'].to(device),
                               token_type_ids=data['token_type_ids'].to(device),
                               attention_mask=data['attention_mask'].to(device))

            fin_probs.append(th.nn.functional.softmax(outputs, dim=1).detach().cpu())

    fin_probs = th.vstack(fin_probs)
    fin_labels = th.argmax(fin_probs, dim=1)
    return fin_labels

# paths
filepaths = {"random":"../data/Test_Sets/validation_set_random_filtered.csv",
             "user":"../data/Test_Sets/validation_set_usrs_filtered.csv",
             "time":"../data/Test_Sets/validation_set_last_entries_filtered.csv"}

# set device
device = th.device("cuda") if th.cuda.is_available() else th.device("cpu")

# load bert uncased
bert_tokenizer_uncased = transformers.BertTokenizer.from_pretrained('bert-base-uncased')
bert_tokenizer_uncased = bert_tokenizer_uncased.from_pretrained("../model/wo_surprise/bert_emoji_tokenizer/")

print(len(bert_tokenizer_uncased))
# add emojis to tokenizer
#with open("../data/emojis.txt", "rb") as fp:
#    emojis = pickle.load(fp)

#bert_tokenizer.add_tokens(emojis)
#print(len(bert_tokenizer))

bert_model_uncased = BERT(
        model=transformers.BertModel.from_pretrained('bert-base-uncased'),
        n_classes=5,
        steps_per_epoch=None,
        n_extra_tokens=len(bert_tokenizer_uncased),
        n_epochs=None,
        loss=th.nn.functional.cross_entropy)

bert_model_uncased.load_state_dict(th.load("../model/wo_surprise/bert_emoji_downsample_True_model.pt"))
bert_model_uncased.to(device)
bert_model_uncased.eval()
bert_model_uncased.freeze()

# load bert cased
bert_tokenizer_cased = transformers.BertTokenizer.from_pretrained('bert-base-cased')
bert_tokenizer_cased = bert_tokenizer_cased.from_pretrained("../model/wo_surprise/bert_emoji_tokenizer_cased/")

bert_model_cased = BERT(
        model=transformers.BertModel.from_pretrained('bert-base-cased'),
        n_classes=5,
        steps_per_epoch=None,
        n_extra_tokens=len(bert_tokenizer_cased),
        n_epochs=None,
        loss=th.nn.functional.cross_entropy)

bert_model_cased.load_state_dict(th.load("../model/wo_surprise/bert_emoji_downsample_True_model_cased.pt"))
bert_model_cased.to(device)
bert_model_cased.eval()
bert_model_cased.freeze()


# load roberta
roberta_tokenizer = transformers.AutoTokenizer.from_pretrained("cardiffnlp/twitter-roberta-base")
roberta_tokenizer = roberta_tokenizer.from_pretrained("../model/wo_surprise/roberta_twitter_tokenizer/")

roberta_model = ROBERTA(
        model=transformers.AutoModel.from_pretrained("cardiffnlp/twitter-roberta-base", return_dict=False),
        n_classes=5,
        steps_per_epoch=None,
        n_epochs=None,
        loss=th.nn.CrossEntropyLoss(reduction="sum"))

roberta_model.load_state_dict(th.load("../model/wo_surprise/roberta_twitter_downsample_True_model.pt"))
roberta_model.to(device)
roberta_model.eval()
roberta_model.freeze()

# hardcoded label conversion
label_dict = {'Affection': 0,
              'Anger': 1,
              'Fear': 2,
              'Happiness': 3,
              'Sadness': 4}

# load existing results table
results = pd.read_csv("../data/model_output/predictions_vent.csv")
print(results.head())
print(len(results))

# predict on all three datasets and save as new file
indizes = [] #should be same as in results file
files = [] #should be same as in results file
bert_cased_predictions = []
bert_uncased_predictions = []
roberta_predictions = []
labels = [] #should be same as in results file

# divide data in chunks to see some progress - takes long
def chunker(seq, size):
    for pos in range(0, len(seq), size):
        yield seq.iloc[pos:pos + size]


for file, filepath in tqdm(filepaths.items()):
    # get the dataset
    df = pd.read_csv(filepath, encoding="utf-8")

    # filter surprise
    df = df[df["label"] != "Surprise"]

    # convert label to number
    df["label"] = [label_dict[label] for label in df["label"]]

    # predict on chunks
    for chunk in tqdm(chunker(df, 100000)):
        # predict bert cased
        predictions_bert_cased = predict_pt(bert_model_cased, bert_tokenizer_cased, chunk, device=device)

        # predict bert uncased
        predictions_bert_uncased = predict_pt(bert_model_uncased, bert_tokenizer_uncased, chunk, device=device)

        # predict roberta
        predictions_roberta = predict_pt(roberta_model, roberta_tokenizer, chunk, device=device)

        # append to lists
        indizes.append(chunk.index)
        files.append(len(chunk) * [file])
        bert_cased_predictions.append(predictions_bert_cased)
        bert_uncased_predictions.append(predictions_bert_uncased)
        roberta_predictions.append(predictions_roberta)
        labels.append(chunk["label"])

        # collect garbage
        gc.collect()

# flatten lists
indizes = list(itertools.chain(*indizes))
files = list(itertools.chain(*files))
bert_cased_predictions = list(itertools.chain(*bert_cased_predictions))
bert_uncased_predictions = list(itertools.chain(*bert_uncased_predictions))
roberta_predictions = list(itertools.chain(*roberta_predictions))
labels = list(itertools.chain(*labels))

# save as csv
results["bert_uncased"] = bert_cased_predictions
results["bert_cased"] = bert_uncased_predictions
results["roberta_twitter"] = roberta_predictions