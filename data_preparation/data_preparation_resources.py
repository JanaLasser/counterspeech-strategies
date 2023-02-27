import re
import pandas as pd


label_pairs = [
    ("batch_1_AS", "batch_1_LT"),
    ("batch_3_AH", "batch_3_AH_LT"),
    ("batch_3_AS", "batch_3_AS_AH"),
    ("batch_3_LT", "batch_3_LT_AH"),
    ("batch_4_AH", "batch_4_AH_AS"),
    ("batch_4_AS", "batch_4_AS_AH"),
    ("batch_4_LT", "batch_4_LT_AH"),
    ("batch_5_LT", "batch_5_LT_AH"),
    ("batch_5_AS", "batch_5_AS_AH"),
    ("batch_5_AH", "batch_5_AH_LT"),
    ("batch_6_AH", "batch_6_AH_LT"),
    ("batch_6_AS", "batch_6_AS_AH"),
    ("batch_6_LT", "batch_6_LT_AH"),
    ("batch_7a_LT", "batch_7a_LT_AH"),
    ("batch_7b_LT", "batch_7b_LT_AH"),
    ("batch_8_LT", "batch_8_LT_EM"),
    ("batch_8_EM", "batch_8_EM_LT"),
    ("batch_9_LT", "batch_9_LT_EM"),
    ("batch_9_EM", "batch_9_EM_LT"),
    ("batch_10_LT", "batch_10_LT_EM"),
    ("batch_10_EM", "batch_10_EM_LT"),
    ("batch_11_LT", "batch_11_LT_EM"),
    ("batch_11_EM", "batch_11_EM_LT"),
    ("batch_12_LT", "batch_12_LT_EM"),
    ("batch_12_EM", "batch_12_EM_LT"),
    ("batch_13_LT", "batch_13_LT_EM"),
    ("batch_13_EM", "batch_13_EM_LT"),
    ("batch_14_EM", "batch_14_EM_AH")
]

def clean_text(df):
    # remove URLs
    df["text"] = df["text"]\
        .apply(lambda x: re.sub(r"https?:\/\/\S*", "", x, flags=re.MULTILINE))
    df = df[df["text"] != None]
    df = df.dropna(subset=["text"])
    df["text"] = df["text"].astype(str)
    df = df.reset_index(drop=True)
    return df


def select_translations(split, classes_to_augment):
    src = "../../../data"
    fname = "backtranslations_filtered_af-ar-cs-da-en-eo-es-et-fi-fr-he-hu-it-no-pl-uk-vi.csv.gzip"
    translations = pd.read_csv(
        fname,
        dtype={"tweet_id":str},
        compression="gzip"
    )
    translations = translations.drop_duplicates(subset=["text"])
    translations["label"] = translations["strategy_human_label"]\
        .replace(label_to_condensed_id)
    # retain only translations from classes we want to augment
    translations = translations[translations["label"].isin(classes_to_augment)]
    # retain only translations from tweets that are in the train split, to
    # avoid information leakage from train to test/eval
    translations = translations[translations["tweet_id"].isin(split["tweet_id"])]
    translations["translation_language"] = translations["translation_language"]\
        .apply(lambda x: x.split("_")[1])
    
    translations["augmentation"] = "trans"
    translations = translations[["tweet_id", "translation", "label", "augmentation"]]
    translations = translations.rename(columns={"translation":"text"})
    translations = translations.sample(frac=1, replace=False)
    translations = clean_text(translations)
    
    return translations


def create_concatenations(split, classes_to_augment):
    # select only texts with <= half the length of the max_sequence_length (180)
    split["text_length"] = split["text"].apply(lambda x: len(x))
    short_texts = split[split["text_length"] <= 90]
    new_texts = pd.DataFrame()

    for c in classes_to_augment:
        indices = short_texts[short_texts["label"] == c].index
        # creates all possible combinations of indices including combinations 
        # where only the order is swapped
        index_combinations = [c for c in permutations(indices, 2)]

        # iterate over all combinations and concatenate the texts
        texts = []
        for comb in index_combinations:
            new_text = short_texts.loc[comb[0], "text"] + " " + \
            short_texts.loc[comb[1], "text"]
            texts.append(new_text)

        df = pd.DataFrame({
            "text":texts,
            "label":[c] * len(texts)
        })
        new_texts = pd.concat([new_texts, df])
    new_texts["augmentation"] = "concat"
    new_texts = new_texts.sample(frac=1, replace=False)
    new_texts = new_texts.reset_index(drop=True)
    split = split.drop(columns=["text_length"])
    
    return new_texts