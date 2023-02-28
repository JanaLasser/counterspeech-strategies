import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import pandas as pd
from torch import cuda

import sys
from datasets import Dataset
import csv

device = 'cuda:0' if cuda.is_available() else 'cpu'


# disable progress manager for tokenizer
from datasets.utils.logging import set_verbosity_error
set_verbosity_error()


# to kill a warning
import os
os.environ["TOKENIZERS_PARALLELISM"] = "false"



# cmd line
model_name=sys.argv[1]


# testing
# model_name='maxpe/twitter-roberta-base-jun2022_sem_eval_2018_task_1'



tokenizer = AutoTokenizer.from_pretrained(model_name)



# change here if you need another type of model
model=AutoModelForSequenceClassification.from_pretrained(model_name)

model.to(device)

# set model to eval mode to get rid of some unnecessary baggage
model.eval()

column_labels=model.config.id2label

model = torch.nn.DataParallel(model)



# cmd line
textfile_str=sys.argv[2]

# testing
# textfile_str='test'

with open(textfile_str,"rb") as textfile:
    # text=textfile.readlines()
    # if file has a header, jump over it
    text=textfile.readlines()[1:]
    text=[x.decode().rstrip("\n") for x in text]
    
# test sentence to compare with the webinterface and pipelines
# https://huggingface.co/maxpe/twitter-roberta-base-jun2022_sem_eval_2018_task_1?text=I+couldn%27t+see+any+seafood+for+a+year+after+I+went+to+that+restaurant+that+they+send+all+the+tourists+to%21 
# text.append("I couldn't see any seafood for a year after I went to that restaurant that they send all the tourists to!")
    
    
# if you know the maximum text length you could change that in the tokenizer, for example for tweets
# but it should not be a big performance issue
# MAX_LEN = 280

# for validation, the larger the batch size the better usually
VALID_BATCH_SIZE = 1000


# tokenize, truncate and pad
inference_dataset = Dataset.from_dict({'text':text}).map(lambda example: tokenizer(example['text'],truncation=True,padding='max_length'))

# remove unnecessary column
inference_dataset=inference_dataset.remove_columns('text')

# prepare for pytorch
inference_dataset = inference_dataset.with_format("torch", device=device)

# set parameters
inference_params = {'batch_size': VALID_BATCH_SIZE,
                'shuffle': False,
                # 'num_workers': 8
                }
# instantiate inference loader
inference_loader = torch.utils.data.DataLoader(inference_dataset,**inference_params)


# at some point maybe something is coming here
# https://huggingface.co/docs/transformers/perf_infer_gpu_many

# clear file and write header to it
with open(textfile_str+"_"+model_name.split('/')[1],"w") as outfile:
    headerwriter=csv.writer(outfile, delimiter='\t')
    headerwriter.writerow(list(column_labels.values()))

# run model and append output to a dataframe
# no_grad is probably not needed because the model is in eval mode already
with torch.no_grad():
    for data in inference_loader:
        outputs = model(**data)
        # change here if you have another type of model that needs a different logits transformation
        fin_outputs=torch.sigmoid(outputs['logits']).cpu().detach().numpy()
        pd.DataFrame(fin_outputs).to_csv(textfile_str+"_"+model_name.split('/')[1],index=False,header=False,sep="\t",mode='a')

