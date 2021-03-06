import $ from 'jquery';
import jQuery from 'jquery';
import 'bootstrap-table';
import './bootstrapTablePrint'

const initTable = (table_id) => {
  var $table = $(table_id)
  var $remove = $('#remove')
  var $toggleExpiredResults = $('#toggle-expired-results')
  var selections = []
  var showExpiredStatus = false
  function getIdSelections() {
    return $.map($table.bootstrapTable('getSelections'), function (row) {
      return row.id
    })
  }

  // function detailFormatter(index, row) {
  //   var html = []
  //   $.each(row, function (key, value) {
  //     html.push('<p><b>' + key + ':</b> ' + value + '</p>')
  //   })
  //   return html.join('')
  // }

  // function operateFormatter(value, row, index) {
  //   return [
  //     '<a class="remove" href="javascript:void(0)" title="Remove">',
  //     '<i class="fa fa-trash"></i>',
  //     '</a>'
  //   ].join('')
  // }

  // window.operateEvents = {
  //   'click .remove': function (e, value, row, index) {
  //     $table.bootstrapTable('remove', {
  //       field: 'id',
  //       values: [row.id]
  //     })
  //   }
  // }

  function expiryFunctions() {
    $table.bootstrapTable('filterBy', {
      expired: "false"
    })
    $(function() {
      $toggleExpiredResults.on( "click", function () {
        if (showExpiredStatus) {
          $table.bootstrapTable('filterBy', {
            expired: "false"
          })
          this.innerHTML = "Show Expired Results"
        } else {
          $table.bootstrapTable('filterBy', {})
          this.innerHTML = "Hide Expired Results"
        }
        showExpiredStatus = !showExpiredStatus
      })
    })
  }

  function initTable() {
    $table.bootstrapTable('destroy').bootstrapTable()
    // $table.on('column-switch.bs.table', function(e, name, args) {
    //   var displayColumn = 'hideColumn'
    //   if (args) {
    //    displayColumn = 'showColumn'
    //   }
    //   $table.bootstrapTable(displayColumn, name)
    // })
    if ($toggleExpiredResults.length) {
      expiryFunctions()
    }
    $table.on('check.bs.table uncheck.bs.table ' +
      'check-all.bs.table uncheck-all.bs.table',
    function () {
      $remove.prop('disabled', !$table.bootstrapTable('getSelections').length)

      // save your data, here just save the current page
      selections = getIdSelections()
      console.log(selections)
      // push or splice the selections if you want to save all data selections
    })
    $table.on('all.bs.table', function (e, name, args) {
      console.log(name, args)
    })
    $remove.on( "click", function () {
      var ids = getIdSelections()
      $table.bootstrapTable('remove', {
        field: 'id',
        values: ids
      })
      $remove.prop('disabled', true)
    })
  }

  $(function() {
    initTable()

    $('#locale').on("change", initTable)
  })
};

export { initTable };
