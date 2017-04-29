R package for managing [CFE database](http://www.cfe-database.org/database/) datasets

# Installation

* Install dependencies
  ```
  install.packages(c('devtools', 'RPostgreSQL', 'dplyr', 'tidyr'))
  ```
  ```
* Install `Reurrep`
  ```
  devtools::install_github('zozlak/Reurrep')
  ```

# Usage

## Adding/updating a dataset

* Load `Reurrep`
  ```
  library(Reurrep)
  ```
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
  import_dataset(dataChecked, 2011, 'yourPassword')
  ```
  You need to manually specify the year, because it is needed to properly sort datasources on the webpage.
* Upload documentation to `sftp://eurrep@zozlak.org` into the `public_html/documentation` directory.  
  Use any SFTP client you want (e.g. FileZilla or WinSCP).
  
## Delete a dataset

```
remove_dataset('country', 'data source name', 'eurrep', 'your password')
```

e.g.
```
remove_dataset('Slovenia', 'Census 01-01-2011', 'myStrongPassword')
```
