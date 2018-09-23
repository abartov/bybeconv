This project will be an evolving set of tools intended to convert the large (~10000 files) collection of icky Word-generated Windows-1255 encoded HTML files of Hebrew works published at http://benyehuda.org, into clean, UTF-8 markdown of some sort -- currently MultiMarkDown -- but just maybe, Docbook or *shudder* TEI.

I make no effort to make the tools general, but if you're looking to do something similar, maybe you can adapt some of my code.

External dependencies:
* Pandoc 1.17.3 or higher for generating ebooks and other formats
* ElasticSearch for search
** https://github.com/synhershko/elasticsearch-analysis-hebrew for the Hebrew analyzer for ElasticSearch
* YAZ and libyaz-dev for the 'zoom' gem for the bibliographic workshop
* watir and selenium for scraping other catalogue systems

License
-------

The code is available for re-use under the GNU Affero General Public License http://www.gnu.org/licenses/agpl-3.0.html
