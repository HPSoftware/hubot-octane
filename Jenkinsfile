/*
Copyright 2016 Hewlett-Packard Development Company, L.P.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copie of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

node {
  /*
    The section below loads Octane-server-related variables. These variables are persisted into a Jenkins config file,
    named 'hubot-octane-config'. To review/edit this file please go to: Jenkins UI -> Jenkins -> Manage Jenkins ->
    Managed Files -> Groovy files -> hubot-octane-config. The format of this file should be:

    env.HUBOT_LOG_LEVEL='<VALUE>'
    env.HUBOT_OCTANE_PROTOCOL='<VALUE>'
    env.HUBOT_OCTANE_HOST='<VALUE>'
    env.HUBOT_OCTANE_PORT='<VALUE>'
    env.HUBOT_OCTANE_CLIENT_ID='<VALUE>'
    env.HUBOT_OCTANE_SECRET='<VALUE>'
    env.HUBOT_OCTANE_SHAREDSPACE='<VALUE>'
    env.HUBOT_OCTANE_WORKSPACE='<VALUE>'
    env.SLACK_APP_TOKEN='<VALUE>'
    env.HUBOT_SLACK_TOKEN='<VALUE>'
  */
  configFileProvider([configFile(fileId: 'hubot-octane-config', targetLocation: 'hubot-octane-config.groovy')]) {
    fileLoader.load('hubot-octane-config.groovy')
  }
}

def pipelineRepo = 'https://github.com/eedevops/he-jenkins-ci.git'
def pipeline = fileLoader.fromGit('integration-flow',
  pipelineRepo, 'master', null, '')
pipeline.runPipeline(pipelineRepo)

