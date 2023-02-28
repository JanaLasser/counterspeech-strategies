# based on this tutorial: https://colab.research.google.com/github/huggingface/notebooks/blob/master/examples/language_modeling.ipynb#scrollTo=DVHs5aCA3l-_

from transformers import AutoTokenizer, DataCollatorForLanguageModeling, BertTokenizer, RobertaTokenizer
from transformers import AutoModelForMaskedLM, Trainer, TrainingArguments
import pandas as pd
from datasets import Dataset, DatasetDict
import math

from pathlib import Path
import sys

EPOCHS = int(sys.argv[1])
BATCH_SIZE = int(sys.argv[2])
MODEL_CHECKPOINT = sys.argv[3]

try:
    TEST = sys.argv[4]
    if TEST == 'test':
        TEST = True
    else:
        print('argument {} not recognized!'.format(TEST))
except IndexError:
    TEST = False

LR = 2e-5

MODEL_SRC = "../models"
DATA_SRC = "../../../data/"
DATA_NAME = "flat_trees_with_text.csv.gzip"

# load the data
if TEST: 
    data = pd.read_csv(
        Path(DATA_SRC, DATA_NAME),
        compression="gzip",
        usecols=["text"],
        nrows=1000
    )
else:
    data = pd.read_csv(
        Path(DATA_SRC, DATA_NAME),
        compression="gzip",
        usecols=["text"],
    )    

data = data.dropna()
data = data.sample(frac=1, random_state=42).reset_index(drop=True)
N = len(data)
val_frac = 0.2

train = Dataset.from_pandas(data[0: int(N * (1 - val_frac))])
val = Dataset.from_pandas(data[int(N * (1 - val_frac)):])

datasets = DatasetDict()
datasets['train'] = train
datasets['validation'] = val

# tokenize
if "gbert" in MODEL_CHECKPOINT:
    tokenizer = BertTokenizer.from_pretrained(
        Path(MODEL_SRC, MODEL_CHECKPOINT),
        use_fast=True
    )
else:
    tokenizer = AutoTokenizer.from_pretrained(
        Path(MODEL_SRC, MODEL_CHECKPOINT),
        use_fast=True
    )
    
def tokenize_function(examples):
    return tokenizer(examples["text"])

tokenized_data = datasets.map(
    tokenize_function, 
    batched=True, 
    num_proc=4, 
    remove_columns=["text"]
)

# set to 512
def group_texts(examples):
    block_size = 128
    # Concatenate all texts.
    concatenated_examples = {k: sum(examples[k], []) for k in examples.keys()}
    total_length = len(concatenated_examples[list(examples.keys())[0]])
    # We drop the small remainder, we could add padding if the model supported 
    # it instead of this drop, you can customize this part to your needs.
    total_length = (total_length // block_size) * block_size
    # Split by chunks of max_len.
    result = {
        k: [t[i : i + block_size] for i in range(0, total_length, block_size)]
        for k, t in concatenated_examples.items()
    }
    result["labels"] = result["input_ids"].copy()
    return result

tokenized_data = tokenized_data.map(
    group_texts,
    batched=True,
    batch_size=1000,
    num_proc=4,
)

model = AutoModelForMaskedLM.from_pretrained(Path(MODEL_SRC, MODEL_CHECKPOINT))

new_model_name = f"{MODEL_CHECKPOINT}_germanhass_epochs-{EPOCHS}_batchsize-{BATCH_SIZE}"
training_args = TrainingArguments(
    new_model_name,
    num_train_epochs=EPOCHS,                  
    per_device_train_batch_size=BATCH_SIZE,  
    per_device_eval_batch_size=BATCH_SIZE,
    evaluation_strategy="epoch",
    save_strategy="epoch",
    learning_rate=2e-5,
    weight_decay=0.01,
    seed = 42,
    load_best_model_at_end=True,
    overwrite_output_dir=True,
    save_total_limit=1,
    gradient_accumulation_steps=8,
    fp16=True
)

data_collator = DataCollatorForLanguageModeling(tokenizer=tokenizer, mlm_probability=0.15)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_data["train"],
    eval_dataset=tokenized_data["validation"],
    data_collator=data_collator,
)

trainer.train()
eval_results = trainer.evaluate()
print(f"Perplexity: {math.exp(eval_results['eval_loss']):.2f}")

trainer.save_model(f"../models/{new_model_name}")