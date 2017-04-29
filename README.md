R package for managing [CFE database](http://www.cfe-database.org/database/) datasets

# Installation

* Install `devtools` package (if you don't have it already)
  ```
  install.packages('devtools')
  ```
* Install `Reurrep`
  ```
  devtools::install_github('zozlak/Reurrep')
  ```

# Usage

## Adding/updating a dataset

* Read the source data (adjust encoding if needed)
  ```
  dataRaw = read.csv('dataFile.csv', stringsAsFactors = FALSE, fileEncoding = 'UTF-8')
  ```
* Check the data (and correct all reported errors)
  ```
  dataChecked = check_dataset(dataRaw)
  ```
* Ingest data into the database (lets assume the dataset is from 2011)
  ```
  import_dataset(data, 2011, 'eurrep', 'yourPassword')
  ```
* Upload documentation to `sftp://eurrep@zozlak.org` into the `public_html/documentation` directory.
  
## Delete a dataset

`remove_dataset('country', 'data source name', 'eurrep', 'your password')`

e.g. `remove_dataset('Slovenia', 'remove_dataset('country', 'data source name', 'eurrep', 'your password')', 'eurrep', 'myStrongPassword')`
