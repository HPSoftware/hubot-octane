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

def pipelineRepo = 'https://github.com/eedevops/he-jenkins-ci.git'
def pipeline = fileLoader.fromGit('integration-flow',
    pipelineRepo, 'master', null, '')

withEnv([
  "HUBOT_LOG_LEVEL=DEBUG",
  "HUBOT_OCTANE_PROTOCOL=http",
  "HUBOT_OCTANE_HOST=myd-vm10629.hpeswlab.net",
  "HUBOT_OCTANE_PORT=8081",
  "HUBOT_OCTANE_CLIENT_ID=sa@nga",
  "HUBOT_OCTANE_SECRET=Welcome1",
  "HUBOT_OCTANE_SHAREDSPACE=1001",
  "HUBOT_OCTANE_WORKSPACE=1002",
  "SLACK_APP_TOKEN=xoxp-39257588437-39207759971-98063563223-591a8de5cf8fd0fadfd04e9337dea4f0",
  "HUBOT_SLACK_TOKEN=xoxb-98052756150-EAOPHS4RDD1MPA8IkeqNDmYo"])
{
  pipeline.runPipeline(pipelineRepo)
}
