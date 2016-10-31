# Notes:
#  Copyright 2016 Hewlett-Packard Development Company, L.P.
#
#  Permission is hereby granted, free of charge, to any person obtaining a
#  copy of this software and associated documentation files (the "Software"),
#  to deal in the Software without restriction, including without limitation
#  the rights to use, copy, modify, merge, publish, distribute, sublicense,
#  and/or sell copie of the Software, and to permit persons to whom the
#  Software is furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.

module.exports = (robot) ->

  Octane = require('octane')
  Query = require('octane/lib/query')

  robot.respond /octane create ticket (.*)/i,(msg) ->
    robot.logger.debug  'in octane create ticket'
    msg.reply 'in octane create ticket'

  if (process.env.HUBOT_OCTANE_PROTOCOL &&
    process.env.HUBOT_OCTANE_HOST &&
    process.env.HUBOT_OCTANE_PORT &&
    process.env.HUBOT_OCTANE_SHAREDSPACE &&
    process.env.HUBOT_OCTANE_WORKSPACE)
      octane = new Octane({
        protocol : process.env.HUBOT_OCTANE_PROTOCOL,
        host :  process.env.HUBOT_OCTANE_HOST,
        port :  process.env.HUBOT_OCTANE_PORT,
        shared_space_id : process.env.HUBOT_OCTANE_SHAREDSPACE,
        workspace_id : process.env.HUBOT_OCTANE_WORKSPACE
      })
  else
    robot.logger.error 'missing hubot-octane environment variables, octane cannot run'
    return


  #check if hubot-enterprise is loaded
#  if robot.e
#    # register integration
#    robot.e.registerIntegration {name: 'octane',
#      short_desc: 'what this integration does',
#      long_desc: 'how this integration does it'}
#
#    #register some functions
#    robot.e.create {verb: 'create', entity: 'ticket',
#      help: 'create ticket', type: 'respond'}, (msg)->
#      robot.logger.debug  'in octane create ticket'
#      msg.reply 'in octane create ticket'
#
#    robot.e.create {verb: 'update', entity: 'ticket',
#      help: 'update ticket', type: 'hear'}, (msg)->
#      robot.logger.debug  'in octane update ticket'
#      msg.send 'in octane update ticket'

  robot.logger.info 'octane initialized'
  robot.hear /octane get defect ([0-9]+)/i,(msg) ->
    robot.logger.debug 'in get defect by id '+JSON.stringify(msg.match)
    octane.authenticate({
      username :  process.env.HUBOT_OCTANE_CLIENT_ID,
      password :  process.env.HUBOT_OCTANE_SECRET
    }, (err) ->
      if (err)
        robot.logger.debug('Error - %s', err.message)
        return
      octane.defects.getAll({
        query: Query.field('id').equal(msg.match[1])
      }, (err, defects) ->
        if (err)
          robot.logger.debug('Error - %s', err.message)
          return
        robot.logger.debug defects.meta.total_count
        if (defects.meta.total_count < 1)
          msg.reply "No defect found"
        for defect in defects
          msg.reply {
            channel : "#{msg.message.room}",
            attachments: JSON.stringify([{
              color: '#7D26CD'
              title: 'ID: ' + defect.id + ' - ' + defect.name
              fields: [
                {
                  title: "Description"
                  value: if defect.description
                  then defect.description.replace(/(<([^>]+)>)/ig,"")
                  else '[empty]'
                  short: false
                },
                {
                  title: "Owner"
                  value: if defect.owner
                  then defect.owner.name
                  else '[empty]'
                  short: true
                },
                {
                  title: "Priority"
                  value: if defect.priority
                  then defect.priority.name
                  else '[empty]'
                  short: true
                },
                {
                  title: "Phase"
                  value: defect.phase.name
                  short: true
                },
                {
                  title: "Severity"
                  value: defect.severity.name
                  short: true
                }]
            }])
          }
      )
    )

  robot.hear /octane search defect (.*)/i,(msg) ->
    robot.logger.debug 'in search defect by text '+msg.match[1]
    octane.authenticate({
      username :  process.env.HUBOT_OCTANE_CLIENT_ID,
      password :  process.env.HUBOT_OCTANE_SECRET
    }, (err) ->
      if (err)
        robot.logger.debug('Error - %s', err.message)
        return
      octane.workItems.getAll({
        text_search: JSON.stringify({
          "type":"global","text":msg.match[1]
        }),query: Query.field('subtype').equal('defect')
      }, (err, defects) ->
        if (err)
          robot.logger.debug('Error - %s', err.message)
          return
        robot.logger.debug defects.meta.total_count
        if (defects.meta.total_count < 1)
          msg.reply "No defect found"
        concatMsg = ''
        for defect in defects
          concatMsg += 'ID: '+defect.id+' | '+'Summary: '+defect.global_text_search_result.name.replace(/(<([^>]+)>)/ig,"")+'\n'
        msg.reply concatMsg
      )
    )

  extractParams = (params) -> #sending msg.match[1] : name=abc,severity=low
    returnParams = []
    for couple in params.split(",")
      returnParams.push({
        fieldName: couple.split("=")[0]
        fieldValue: couple.split("=")[1]
      })
    return returnParams

  robot.hear /octane update defect ([0-9]+ )(.*)/i,(msg) ->
    robot.logger.debug 'in update defect'
    octane.authenticate({
      username :  process.env.HUBOT_OCTANE_CLIENT_ID,
      password :  process.env.HUBOT_OCTANE_SECRET
    }, (err) ->
      if (err)
        robot.logger.debug('Error - %s', err.message)
        return

      fields = extractParams(msg.match[2])
      fieldName = fields[0].fieldName
      fieldValue = fields[0].fieldValue

      listNode = 'list_node.'+fieldName+'.'+fieldValue
      octane.listNodes.getAll({
        query: Query.field('logical_name').equal(listNode)
      }, (err, listNodes) ->
        if (err)
          robot.logger.debug('Error - %s', err.message)
          return
        update = {
          id: msg.match[1]
        }
        if listNodes[0]
        then update[fieldName] = listNodes[0]
        else update[fieldName] = fieldValue
        octane.defects.update(update, (err, updated)->
          if err
            msg.reply 'defect was not updated- check your syntax'
            robot.logger.debug('Error - %s', err.message)
            return
          msg.reply 'defect '+updated.id+' updated successfully'
        )

      )
    )

  robot.hear /octane create defect (.*)/i,(msg) ->
    robot.logger.debug 'in create defect'
    octane.authenticate({
      username :  process.env.HUBOT_OCTANE_CLIENT_ID,
      password :  process.env.HUBOT_OCTANE_SECRET
    }, (err) ->
      if (err)
        robot.logger.debug('Error - %s', err.message)
        return

      octane.workItems.getAll({
        query: Query.field('subtype').equal('work_item_root')
      }, (err, wis)->
        if (err)
          robot.logger.debug('Error - %s', err.message)
          return
        high = 'list_node.severity.very_high'
        octane.listNodes.getAll({
          query: Query.field('logical_name').equal(high)
        }, (err, severities) ->
          if (err)
            robot.logger.debug('Error - %s', err.message)
            return

          octane.phases.getAll({
            query: Query.field('logical_name').equal('phase.defect.new')
          }, (err, phases) ->
            if (err)
              robot.logger.debug('Error - %s', err.message)
              return
            defect = {
              name: msg.match[1],
              parent: wis[0],
              severity: severities[0],
              phase: phases[0]
            }
            octane.defects.create(defect, (err, defect) ->
              if (err)
                robot.logger.debug('Error - %s', err.message)
                return
              msg.reply "defect created successfully. ID: "+defect.id
            )
          )
        )
      )
    )




