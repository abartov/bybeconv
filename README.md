This codebase runs https://benyehuda.org -- the Project Ben-Yehuda digital library of works in Hebrew.

I make little effort to make the code general, but if you're looking to do something similar (e.g. a digital library in Yiddish), maybe you can adapt some of my code.

External (i.e. hosting system) dependencies:
* Pandoc 2.10 or higher for generating ebooks and other formats. (previous versions skip SmartTag tags in DOCX files, causing random letters to disappear in certain DOCXes with extraneous mark-up.
* wkhtmltopdf for PDF generation
* ElasticSearch for search
** https://github.com/synhershko/elasticsearch-analysis-hebrew for the Hebrew analyzer for ElasticSearch
* YAZ and libyaz-dev for the 'zoom' gem for the bibliographic workshop
* watir and selenium for scraping other catalogue systems
* libpcap-dev for net-dns2
* libmagickwand-dev for RMagick
* libmysqlclient-dev for mysql2
* sidekiq for scheduled jobs [using systemd](https://github.com/sidekiq/sidekiq/wiki/Deployment)
* redis as [backend for sidekiq](https://github.com/sidekiq/sidekiq/wiki/Using-Redis)
* memcached for caching

License
-------

The code is available for re-use under the GNU Affero General Public License http://www.gnu.org/licenses/agpl-3.0.html
