#%%
import torch
from transformers import BertForSequenceClassification, ElectraForSequenceClassification
from transformers import BertTokenizerFast, ElectraTokenizerFast
from transformers import Trainer, TrainingArguments
from tqdm import tqdm
from datasets import load_dataset,load_metric
from collections import Counter
import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import cross_val_score

#loads a test dataset to play with
#raw_datasets = load_dataset("imdb")
"""
#This set of code is for our RG/RI Dataset can be ignored for now
#Load the RG/RI train test set. This is a small subset for practice. 
"""""
#data_label= "dataset1"
data_label= "datasetDE"
raw_datasets = load_dataset('json', data_files={"train":data_label+"_train.json","test":data_label+"_test.json"})

print("\n\nLoaded ", data_label,"!!\n\n\n")

#Function needed for assesing prediction
metric = load_metric("accuracy")

def compute_metrics(eval_pred):
    logits, labels = eval_pred
    predictions = np.argmax(logits, axis=-1)
    return metric.compute(predictions=predictions, references=labels)

#Processing function 


#%%



def main():
    """model_name is to select which BERT we are using"""
    #model_name = 'deepset/gbert-large'
    #model_name = "bert-base-uncased"
    model_name = 'deepset/gbert-base'

    """This tells Transformers which classes we will use"""
    tokenizer_class = BertTokenizerFast
    model_class = BertForSequenceClassification

    """
    max_length is the max length of any tweet (in words). Less than this
    and null tokens are added, more and it is truncated. Can be lowered
    to help with Ram needs 256 was  reccomended. In our dataset 81 is the max length of a twweet so moving this to 100 to help with runtime for now.
    """
    max_length = 100
    """
    load the pretrained model
    """
    model = model_class.from_pretrained(model_name,num_labels=2, output_hidden_states=True)
    tokenizer = tokenizer_class.from_pretrained(model_name)


    def tokenize_function(tweets_to_convert):
        return tokenizer(tweets_to_convert["text"], padding="max_length", truncation=True,max_length=max_length)


    torch.save(model.state_dict(), './model_before.pth')

    #%%
    #Tokenize the dataset. Also adds attention masks, padding and other things
    tokenized_datasets = raw_datasets.map(tokenize_function, batched=True)
    """
    Trainer is what allows us to fine tune the <model_name> from 
    above. 
    TrainingArguments is where you specify training params
    per_device_train_batch_size and per_device_eval_batch_size 
    can be increased decreased depending on memory that is availble
    If you have <12GB ram per GPU then this should be set to 1.
    If however you have more this can be increased. With 24G per core
    we went up to 16 on these. If you run out memory this is the 
    first place o start tuning.
    """
    training_args = TrainingArguments("test_trainer",
    eval_accumulation_steps=1,
    per_device_train_batch_size =256,
    per_device_eval_batch_size=256,
    num_train_epochs=5,
    )# %%
    
    #%%
    """
    Randomly select small subset to play with
    """
    for i in tqdm(range(1)):

        model.load_state_dict(torch.load('./model_after.pth'))

        model = model_class.from_pretrained(model_name,num_labels=2)

        rand_train_dataset = tokenized_datasets["train"]#.shuffle(seed=i).select(range(10000))
        rand_eval_dataset = tokenized_datasets["test"]#.shuffle(seed=i).select(range(1000))
        
        print("\n Random Training split",Counter(rand_train_dataset["label"]))
        print("\n Random Eval split",Counter(rand_eval_dataset["label"]))

        #print(rand_train_dataset)
    
        """
        Trainer is the function that actually does the fine tunning.
        This next call just sets up the object.
        """
        trainer = Trainer(
        model = model,
        args = training_args,
        train_dataset = rand_train_dataset,
        eval_dataset = rand_eval_dataset,
        compute_metrics = compute_metrics,
        )
        """
        trainer.train() does the fine tuning. If this runs out of RAM see above
        """
        trainer.train()

        # %%
        """
        trainer.evaluate() let's you know how accurate predictions were
        """
        scores = trainer.evaluate()
        
        print("\n\n New SCORES!!!!!!")
        print(scores['eval_accuracy'])
        print("\n")

        #small_train_dataset = tokenized_datasets["train"].shuffle(seed=2).#select(range(500))
        #small_eval_dataset = tokenized_datasets["test"].shuffle(seed=2).#select(range(500))

        #%%
        torch.save(model.state_dict(), './model_after.pth')
        
        #print(rand_train_dataset)
        #%%

'''
        input_ids = torch.tensor(np.array(rand_train_dataset["input_ids"]))

        #print(rand_train_dataset["input_ids"])

        # Include the attention mask. 
        model = model.to("cpu")
        with torch.no_grad():
            last_hidden_states = model(input_ids)

        #print(last_hidden_states)
        
        train_features = last_hidden_states[0][:,0,:].numpy()
        train_labels = np.array(rand_train_dataset["labels"])

        # %%
        input_ids = torch.tensor(np.array(rand_eval_dataset["input_ids"]))

        model = model.to("cpu")
        with torch.no_grad():
            last_hidden_states = model(input_ids)

        test_features = last_hidden_states[0][:,0,:].numpy()
        test_labels = np.array(rand_eval_dataset["labels"])

        lr_clf = LogisticRegression()
        lr_clf.fit(train_features, train_labels)
        # %%
        lr_clf.score(test_features, test_labels)
'''

    
    # %%
if __name__ == "__main__":
    main()
