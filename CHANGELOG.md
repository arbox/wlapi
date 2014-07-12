## COMPLETED
### 0.8.6
Implemented <tt>ngrams</tt> and <tt>ngram_references</tt>.
### 0.8.5
Finished the port to <tt>Savon 2</tt>.
### 0.8.4
Imlemented the <tt>API#crossword</tt> method for the prefix/suffix search.
### 0.8.3
Implemented a simple error handling strategy, it is possible to intercept
the <tt>WLAPI::Error</tt> which covers all error types.

Added error for inconvinient user argumets.

Added new tests and refactored old tests.
### 0.8.1
Moved to dependency management via Bundler.
### 0.8.0
WLAPI depends on Savon <tt>>=0.8.0</tt>
with all interface changes have been implemented.

### 0.7.4
Small fixes in the project infrastructure and test refactoring.
### 0.7.3
Fixed the bug with a wrong dependency on the latest version of savon.
Due to interface changes it depends now on <tt>0.7.9</tt>.
### 0.0.3
Initial release of the lib.


## PLANNED
### 0.8.7
  - Adjust gem version in <tt>Gemfile</tt>.
  - Rewrite tests using <tt>Minitest</tt>.
  - Test the lib against mri, rbx, jruby, win rubies.
  - Introduce <tt>nokogiri</tt> for parsing responses.
  - Refine semantic checks for two parameter methods.

### 0.8.8
### 0.8.9

### 0.9.0
Add a command line tool to work with Wortschatz Lepzip. Package the lib, the cmd tool, and all the dependencies. Nokogiri is packaged by Lucas Nussbaumer.
### 1.0.0
