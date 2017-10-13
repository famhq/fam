z = require 'zorium'
Rx = require 'rxjs'
_map = require 'lodash/map'
_sumBy = require 'lodash/sumBy'
_take = require 'lodash/take'

GraphWidget = require '../graph_widget'
FlatButton = require '../flat_button'
UpdateRecordDialog = require '../group_update_record_dialog'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupManageMemberRecords
  constructor: ({@model, group, user, @overlay$}) ->

    groupAndUser = Rx.Observable.combineLatest(
      group
      user
      (vals...) -> vals
    )
    records = groupAndUser.switchMap ([group, user]) =>
      @model.groupRecord.getAllByUserIdAndGroupId {
        groupId: group.id
        userId: user.id
      }

    @$updateRecordDialog = new UpdateRecordDialog {@overlay$}

    @state = z.state
      group: group
      user: user
      records: records.map (records) ->
        _map records, (record) ->
          {
            record
            $graph: new GraphWidget()
            $updateButton: new FlatButton()
          }

  render: =>
    {group, user, records} = @state.getValue()

    z '.z-group-manage-member-records',
      z @$graphWidget, {labels: ['a'], series: [[1]]}
      _map records, ({$graph, $updateButton, record}) =>
        {recordType, records} = record
        thisWeekValue = records[0]?.value
        thisWeekValueStr = if thisWeekValue? then thisWeekValue else 'n/a'
        lastWeekValue = records[1]?.value
        lastWeekValueStr = if lastWeekValue? then lastWeekValue else 'n/a'
        monthValue = _sumBy _take(records, 4), 'value'
        graphSeries = _map records, ({value}) -> parseInt value

        z '.record-type',
          z '.name', "#{recordType.name} / #{recordType.timeScale}"
          z '.stats',
            z '.stat',
              z '.value', thisWeekValueStr
              z '.title', "this #{recordType.timeScale}"
            z '.stat',
              z '.value', lastWeekValueStr
              z '.title', "last #{recordType.timeScale}"
            z '.stat',
              z '.value', monthValue
              z '.title', 'past month'
          z '.graph',
            z $graph, {
              labels: [recordType.name]
              series: [graphSeries]
              options:
                lineSmooth: false
                axisY:
                  onlyInteger: true
                  showGrid: true
                axisX:
                  showLabel: false
                  showGrid: false
            }
          z '.actions',
            z $updateButton,
              text: 'Update'
              isFullWidth: false
              onclick: =>
                @$updateRecordDialog.setValue thisWeekValue or ''
                @overlay$.next(
                  z @$updateRecordDialog, {
                    recordType
                    onSave: (value) =>
                      @model.groupRecord.save {
                        userId: user.id
                        groupRecordTypeId: recordType.id
                        value: value
                      }
                  }
                )
