import pandas as pd
from pathlib import Path
from transformers import MarianMTModel, MarianTokenizer
import torch
import sys

# see also https://huggingface.co/Helsinki-NLP for possible translations
# afar,cs,da,en,eo,es,et,fi,fr,he,hu,it,no,pl,uk,vi
languages = sys.argv[1]
languages = languages.split(",")

try:
    testing = sys.argv[2]
    if testing == "test": 
        testing = True
    else: 
        print("unknown argument")
        testing = False
except IndexError:
    testing = False

src = "../../../data/inferred"
fname = "inferred_data.csv.gzip"

device = "cuda"

cols = ["tweet_id", "text", "strategy_human_label", "strategy",
        "strategy_construct", "strategy_opin", "strategy_sarc",
        "strategy_leave_fact", "strategy_other_new"]
data = pd.read_csv(
    Path(src, fname),
    compression="gzip",
    dtype={"tweet_id":str},
    usecols=cols
)

# drop the data from the test set
data = data.\
    dropna(subset=["strategy_human_label"])\
    .copy()\
    .reset_index(drop=True)\
    [["tweet_id", "text", "strategy_human_label"]]

if testing:
    data = data[0:1000]

def format_batch_texts(text, language_code):
    return ">>{}<< {}".format(language_code, text)

def chunks(lst, n):
    """Yield successive n-sized chunks from lst."""
    for i in range(0, len(lst), n):
        yield lst[i : i + n]

def translate(target_lang, data, chunk_size=512):
    to_translate = [format_batch_texts(t, target_lang) for t in data]
    if testing: to_translate = to_translate[0:1000]
    
    model1_name = f'Helsinki-NLP/opus-mt-de-{target_lang}'
    model2_name = f'Helsinki-NLP/opus-mt-{target_lang}-de'
    model1 = MarianMTModel.from_pretrained(model1_name).to(device).half()
    model2 = MarianMTModel.from_pretrained(model2_name).to(device).half()
    tok1 = MarianTokenizer.from_pretrained(model1_name)
    tok2 = MarianTokenizer.from_pretrained(model2_name)
    
    translations = []
    for src_text_list in chunks(to_translate, chunk_size): 
        trans = model1.generate(
            **tok1(src_text_list,
                   return_tensors="pt",
                   padding="max_length",
                   max_length=180,
                   truncation=True
                  ).to(device))
        trans = [tok1.decode(t).replace("<pad>", "").strip(" ")\
                 for t in trans]
        translations.extend(trans)
        
    translations = [format_batch_texts(t, language_code="de") \
                    for t in translations]
    
    backtranslations = []
    for src_text_list in chunks(translations, chunk_size): 
        trans = model2.generate(
            **tok2(src_text_list,
                   return_tensors="pt",
                   padding="max_length",
                   max_length=180,
                   truncation=True
                  ).to(device))
        trans = [tok2.decode(t).replace("<pad>", "").strip(" ")\
                 for t in trans]
        backtranslations.extend(trans)
    
    del model1
    del model2
    del tok1
    del tok2
    torch.cuda.empty_cache()
    return backtranslations
    

for language in languages:
    print(f"translating to {language}")
    backtranslations = translate(language, data["text"], chunk_size=256)
    data[f"translation_{language}"] = backtranslations
    data.to_csv("backtranslations.csv", index=False)