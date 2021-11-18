# counterspeech-strategies

## ToDos
- [ ] 

## Fine tuning parameters
* `train_batch_size`
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
| 2021-11-18 | twitter-xlm-roberta-base | 10k, DE | not set | 128 | f1 | 0.673 | 4.5 min |