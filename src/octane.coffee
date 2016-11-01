# Description:
#   Interact octane
#
# Dependencies:
#   node-octane
#
#
# Commands:
#   octane get defect [id]
#   octane search defect [text]
#   octane update defect [id] [fieldName]=[fieldValue]
#   octane create defect name=[name],severity=[severity]
#
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
    errorStr = 'missing hubot-octane environment variables, octane cannot run'
    robot.logger.error errorStr
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
  robot.hear /octane get (defect|story) ([0-9]+)/i,(msg) ->
    robot.logger.debug 'in get defect by id '+JSON.stringify(msg.match)
    octane.authenticate({
      username :  process.env.HUBOT_OCTANE_CLIENT_ID,
      password :  process.env.HUBOT_OCTANE_SECRET
    }, (err) ->
      if (err)
        robot.logger.debug('Error - %s', err.message)
        return
      entityName = msg.match[1]
      pluralEntityName = entityName + 's'
      if entityName is 'story'
        pluralEntityName = 'stories'
      octane[pluralEntityName].getAll({
        query: Query.field('id').equal(msg.match[2])
      }, (err, entities) ->
        if (err)
          robot.logger.debug('Error - %s', err.message)
          return
        robot.logger.debug entities.meta.total_count
        if (entities.meta.total_count < 1)
          msg.reply "No "+entityName+" found"
        for entity in entities
          msg.reply {
            channel : "#{msg.message.room}",
            attachments: JSON.stringify([{
              color: '#7D26CD'
              title: 'ID: ' + entity.id + ' - ' + entity.name
              fields: [
                {
                  title: "Description"
                  value: if entity.description
                  then entity.description.replace(/(<([^>]+)>)/ig,"")
                  else '[empty]'
                  short: false
                },
                {
                  title: "Owner"
                  value: if entity.owner
                  then entity.owner.name
                  else '[empty]'
                  short: true
                },
                {
                  title: "Priority"
                  value: if entity.priority
                  then entity.priority.name
                  else '[empty]'
                  short: true
                },
                {
                  title: "Phase"
                  value: entity.phase.name
                  short: true
                },
                {
                  title: "Severity"
                  value: if entity.severity
                  then entity.severity.name
                  else '[empty]'
                  short: true
                }]
            }])
          }
      )
    )

  robot.hear /octane search (defect|story) (.*)/i,(msg) ->
    robot.logger.debug 'in search entity by text '+msg.match[2]
    octane.authenticate({
      username :  process.env.HUBOT_OCTANE_CLIENT_ID,
      password :  process.env.HUBOT_OCTANE_SECRET
    }, (err) ->
      if (err)
        robot.logger.debug('Error - %s', err.message)
        return
      entityName = msg.match[1]
      octane.workItems.getAll({
        text_search: JSON.stringify({
          "type":"global","text":msg.match[2]
        }),query: Query.field('subtype').equal(entityName)
      }, (err, entities) ->
        if (err)
          robot.logger.debug('Error - %s', err.message)
          return
        robot.logger.debug entities.meta.total_count
        if (entities.meta.total_count < 1)
          msg.reply "No "+entityName+" found"
        concatMsg = ''
        for entity in entities
          concatMsg += 'ID: '+entity.id+
              ' | '+'Summary: '+
              entity.
              global_text_search_result.name.replace(/(<([^>]+)>)/ig,"")+
              '\n'
        msg.reply concatMsg
      )
    )

  extractParams = (params) -> # name=abc,severity=low
    returnParams = []
    for couple in params.split(",")
      fieldName = couple.split("=")[0]
      fieldValue = couple.split("=")[1]
      returnParams[fieldName] = fieldValue
    return returnParams

  robot.hear /octane update (defect|story) ([0-9]+ )(.*)/i,(msg) ->
    robot.logger.debug 'in update defect'
    octane.authenticate({
      username :  process.env.HUBOT_OCTANE_CLIENT_ID,
      password :  process.env.HUBOT_OCTANE_SECRET
    }, (err) ->
      if (err)
        robot.logger.debug('Error - %s', err.message)
        return

      entityName = msg.match[1]
      pluralEntityName = entityName + 's'
      if entityName is 'story'
        pluralEntityName = 'stories'

      fieldName = msg.match[3].split("=")[0]
      fieldValue = msg.match[3].split("=")[1]

      listNode = 'list_node.'+fieldName+'.'+fieldValue
      octane.listNodes.getAll({
        query: Query.field('logical_name').equal(listNode)
      }, (err, listNodes) ->
        if (err)
          robot.logger.debug('Error - %s', err.message)
          return
        update = {
          id: msg.match[2]
        }
        if listNodes[0]
        then update[fieldName] = listNodes[0]
        else update[fieldName] = fieldValue
        octane[pluralEntityName].update(update, (err, updated)->
          if err
            msg.reply entityName+' was not updated- check your syntax'
            robot.logger.debug('Error - %s', err.message)
            return
          msg.reply entityName+' '+updated.id+' updated successfully'
        )

      )
    )

  robot.hear /octane create (defect|story) (.*)/i,(msg) -> #create defect name=abc,severity=high /
    robot.logger.debug 'in create defect'
    octane.authenticate({
      username :  process.env.HUBOT_OCTANE_CLIENT_ID,
      password :  process.env.HUBOT_OCTANE_SECRET
    }, (err) ->
      if (err)
        robot.logger.debug('Error - %s', err.message)
        return
      params = extractParams(msg.match[2])
      entityName = msg.match[1]
      pluralEntityName = entityName + 's'
      if entityName is 'story'
        pluralEntityName = 'stories'
      octane.workItems.getAll({
        query: Query.field('subtype').equal('work_item_root')
      }, (err, wis)->
        if (err)
          robot.logger.debug('Error - %s', err.message)
          return
        severityValue = 'list_node.severity.'+params['severity']
        octane.listNodes.getAll({
          query: Query.field('logical_name').equal(severityValue)
        }, (err, severities) ->
          if (err)
            robot.logger.debug('Error - %s', err.message)
            return
          newPhase = 'phase.'+entityName+'.new'
          octane.phases.getAll({
            query: Query.field('logical_name').equal(newPhase)
          }, (err, phases) ->
            if (err)
              robot.logger.debug('Error - %s', err.message)
              return
            entity = {
              name: params['name'],
              parent: wis[0],
              severity: severities[0],
              phase: phases[0]
            }
            octane[pluralEntityName].create(entity, (err, created) ->
              if (err)
                robot.logger.debug('Error - %s', err.message)
                return
              msg.reply entityName+" created successfully. ID: "+created.id
            )
          )
        )
      )
    )




