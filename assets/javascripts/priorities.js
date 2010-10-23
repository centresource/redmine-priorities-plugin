jQuery.noConflict();
jQuery(document).ready(function($) {
  $('.priority-choice input:radio').change(function() {
    var type = $(this).val();
    
    if (type == 'general') {
      $('#priority-title-container').show();
      $('#priority-assigned-to-container').show();
      $('#priority-references-container').hide();
      $('#priority_issue_id option:first').attr("selected", "selected");
    } else if (type == 'issue') {
      $('#priority-references-container').show();
      $('#priority-title-container').hide();
      $('#priority-assigned-to-container').hide();
      // reset values
      $('#priority-title-container input').val('');
      $("#priority-assigned-to-container option:first").attr("selected", "selected");
    }
  });
});