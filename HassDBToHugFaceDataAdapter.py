import os,sys
#sys.path.append("../") 

from germanhass.DBCode.HassDBAdapter import HassDBAdapter
from germanhass.Model import Model 
from transformers import AutoTokenizer,BertForSequenceClassification
from tqdm import tqdm
from nltk.corpus import stopwords
from datasets import load_dataset
import json, io

db = HassDBAdapter()
max_length = 256

data_label = "datasetDE"
#cur_hate = list(db.hate_tweets_coll.find({"training_set": data_label}))

#cur_counter = db.counter_tweets_coll.find({"training_set": data_label})

#my_dataset = load_dataset('json', data_files='my_file.json')

model_class = BertForSequenceClassification
model_name = 'deepset/gbert-base'

tokenizer_class = AutoTokenizer
tokenizer = tokenizer_class.from_pretrained(model_name)

def tokenize_function(tweets_to_convert):
    return tokenizer(tweets_to_convert["text"], padding="max_length", truncation=True,max_length=max_length)

def dataset_to_json(ds, filename):
    if type(ds) == dict:
        with io.open(filename, 'a', encoding='utf8') as outfile:
            outfile.write(json.dumps(
                ds, ensure_ascii=False))
            outfile.close()
    elif type(ds) == list:
        with io.open(filename, 'a', encoding='utf8') as outfile:
            for tweet in ds:
                outfile.write(json.dumps(tweet, ensure_ascii=False))
                outfile.write("\n")
            outfile.close()
    else:
        print(ds, "unknown cache type")


def Tweets_to_HF(
            data_label):
        """
            This function converts the specified set of tweets and converts it
            into the proper format for Hugging Face models
        """
        
        stop_words = {'als', 'also', 'am', 'an',
                               'auf', 'aus', 'bei', 'bis', 'da', 'damit',
                               'dann', 'das', 'daß', 'dass', 'dem', 'den',
                               'der', 'des', 'die', 'dies', 'ein', 'eine',
                               'einem', 'einen', 'einer', 'eines',
                               'einige', 'einigem', 'einigen', 'einiger',
                               'einiges', 'es', 'im', 'in', 'ins', 'ob',
                               'oder', 'so', 'sondern', 'um', 'und', 'unter',
                               'vom', 'von', 'vor', 'zu', 'zum', 'zur'}

        stop_words = set(stopwords.words('german'))
        # TODO: Remove the data limits and the list(). 

        #cur_hate_num = db.hate_tweets_coll.count_documents({"training_set": data_label})
        cur_hate = list(db.hate_tweets_coll.find({"training_set": data_label}))[0:50000]
        #cur_counter_num = db.counter_tweets_coll.count_documents({"training_set": data_label})
        cur_counter = list(db.counter_tweets_coll.find({"training_set": data_label}))[0:50000]

        train_dataset = []
        for x in tqdm(cur_hate,total=100):
            new_json ={}

            # Remove stop words. 
            tokens = [i for i in x["tokens"] if i not in stop_words]
            new_json["text"]= ' '.join(tokens)
            new_json["label"]=0
            train_dataset.append(new_json)
            
        for x in tqdm(cur_counter,total=100):
            new_json ={}

            # Remove stop words. 

            tokens = [i for i in x["tokens"] if i not in stop_words]
            new_json["text"]= ' '.join(tokens)
            new_json["label"]=1
            train_dataset.append(new_json)

        dataset_to_json(train_dataset, data_label+"_train.json")
        
        # TODO: Remove dataset limitations and list(). 

        #cur_hate_num = db.hate_tweets_coll.count_documents({"test_set": data_label})
        cur_hate = list(db.hate_tweets_coll.find({"test_set": data_label}))[0:5000]
        #cur_counter_num = db.counter_tweets_coll.count_documents({"test_set": data_label})
        cur_counter = list(db.counter_tweets_coll.find({"test_set": data_label}))[0:5000]

        test_dataset = []
        for x in tqdm(cur_hate,total=100):
            new_json ={}

            # Remove stop words

            tokens = [i for i in x["tokens"] if i not in stop_words]
            new_json["text"]= ' '.join(tokens)
            new_json["label"]=0
            test_dataset.append(new_json)
        for x in tqdm(cur_counter,total=100):
            new_json ={}

            # Remove stop words

            tokens = [i for i in x["tokens"] if i not in stop_words]
            new_json["text"]= ' '.join(tokens)
            new_json["label"]=1
            test_dataset.append(new_json)

        dataset_to_json(test_dataset, data_label+"_test.json")

        raw_dataset = load_dataset('json', data_files={"train":data_label+"_train.json","test":data_label+"_test.json"})

        tokenized_datasets = raw_dataset.map(tokenize_function, batched=True)


Tweets_to_HF(data_label=data_label)