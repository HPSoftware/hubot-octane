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

  Octane = require('node-octane')
  Query = require('../../node-octane/lib/query')

  octane = new Octane({
    protocol : "http",
    host :  "XXX",
    port :  8081,
    shared_space_id : 1001,
    workspace_id : 1002
  })


  #check if hubot-enterprise is loaded
  if not robot.e
    robot.logger.error 'hubot-enterprise not present, octane cannot run'
    return
  robot.logger.info 'octane initialized'

  # register integration
  robot.e.registerIntegration {name: 'octane',
  short_desc: 'what this integration does',
  long_desc: 'how this integration does it'}

  #register some functions
  robot.e.create {verb: 'get', entity: 'defect',
  help: 'get defect by id', type: 'hear'},
    (msg)->
      robot.logger.debug 'in get defect by id'
      octane.authenticate({
        username :  "",
        password :  ""
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
            textDefect = "Defect ID: "+defect.id
            textDefect += "\nName: "+defect.name
            textDefect += "\nSeverity: "+defect.severity.name
            message =
              text: textDefect
              color: "warning"
            robot.e.adapter.message msg, message, false
        )
      )

  robot.e.create {verb: 'search', entity: 'defect',
  help: 'search defect by text', type: 'hear'},
    (msg)->
      robot.logger.debug 'in search defect by text'
      octane.authenticate({
        username :  "",
        password :  ""
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
          for defect in defects
            textDefect = "Defect ID: "+defect.id
            textDefect += "\nName: "+defect.global_text_search_result.name
            defectDesc = defect.global_text_search_result.description
            textDefect += "\nDescription: "+defectDesc
            message =
              text: textDefect
              color: "warning"
            robot.e.adapter.message msg, message, false
        )
      )

  #  robot.e.create {verb: 'update', entity: 'defect',
  #  help: 'update defect', type: 'hear'},
  #    (msg)->
  #      robot.logger.debug 'in update defect'
  #      octane.authenticate({
  #        username :  "",
  #        password :  ""
  #      }, (err) ->
  #        if (err)
  #          robot.logger.debug('Error - %s', err.message)
  #          return
  #        octane.listNodes.getAll({ query: Query.field('logical_name').equal('list_node.severity.very_high') }, (err, severities) ->
  #          if (err)
  #            robot.logger.debug('Error - %s', err.message)
  #            return
  #
  #          octane.phases.getAll({ query: Query.field('logical_name').equal('phase.defect.new') }, (err, phases) ->
  #            if (err)
  #              robot.logger.debug('Error - %s', err.message)
  #              return
  #            defect = {
  #              name: msg.match[1],
  #              parent: wis[0],
  #              severity: severities[0],
  #              phase: phases[0]
  #            }
  #            octane.defects.create(defect, (err, defect) ->
  #              if (err)
  #                robot.logger.debug('Error - %s', err.message)
  #                return
  #              message =
  #                title: "Defect create successfully"
  #                text: "Description: "+msg.match[1]
  #                color: "good"
  #              robot.e.adapter.message msg, message, false
  #            )
  #          )
  #        )
  #      )

  robot.e.create {verb: 'create', entity: 'defect',
  help: 'create defect', type: 'hear'},
    (msg)->
      robot.logger.debug 'in create defect'
      octane.authenticate({
        username :  "",
        password :  ""
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
                message =
                  title: "Defect create successfully"
                  text: "Description: "+msg.match[1]
                  color: "good"
                robot.e.adapter.message msg, message, false
              )
            )
          )
        )
      )




