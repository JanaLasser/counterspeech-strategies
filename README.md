# counterspeech-strategies

## ToDos
- [x] implement training workflow following [this](https://towardsdatascience.com/transformers-can-you-rate-the-complexity-of-reading-passages-17c76da3403) example
- [ ] test new training workflow implementation
- [ ] implement layer-wise learning rate decay
- [ ] implement warm-up steps
- [ ] implement layer re-initialization
- [ ] implement stochastic weight averaging
- [ ] implement frequent evaluation

## Fine tuning parameters
### Model
* Learnings:
    * gbert-base and twitter-xlm-roberta-base perform similarly well in terms of accuracy
    
### Sequence length
* testing 50k tokenized sequences (XLMRobertaTokenizerFast), the maximum number of non-pad tokens in a tokenized text was 94 and only 6.8% of texts had more than 60 non-pad tokens (including special tokens).
### `train_batch_size`
* Learnings:
    * 10k rows: smaller batch sizes (128 vs 512) improve accuracy

* layer-wise learning rate decay
* warm-up steps
* re-initialization of the top n layers
* stochastic weight averaging
* frequent evaluation

## Fine tuning experiments
| date | model | data | epochs | learning rate | train batch size | eval metric | result | train time |
| ---- | ----- | ------ | ------ | ------------- | ---------------- | ----------- | ------ |
| 2021-11-18 | gbert-base | 50k, DE | not set | 256 | accuracy | 0.7572 | ~20 min |
| 2021-11-18 | twitter-xlm-roberta-base | 50k, DE | not set | 256 | accuracy | 0.7545 | 45 min |
| 2021-11-18 | twitter-xlm-roberta-base | 10k, DE | not set | 256 | accuracy | 0.669 | 4.5 min |
| 2021-11-18 | twitter-xlm-roberta-base | 10k, DE | not set | 512 | accuracy | 0.651 | 4.5 min |
| 2021-11-18 | twitter-xlm-roberta-base | 10k, DE | not set | 128 | accuracy | 0.673 | 4.5 min |
| 2021-11-18 | twitter-xlm-roberta-base | 10k, DE | not set | 128 | f1 | 0.6835 | 5 min |
| 2021-11-18 | twitter-xlm-roberta-base | 10k, DE | not set | 64 | f1 | 0.6828 | 5.5 min |