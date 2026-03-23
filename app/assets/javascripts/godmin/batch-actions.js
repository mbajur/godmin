window.Godmin = window.Godmin || {};

Godmin.BatchActions = (function() {
  var $container;
  var $selectAll;
  var $selectNone;

  function initialize() {
    $container  = $('[data-behavior~=batch-actions-container]');
    $selectAll  = $container.find('[data-behavior~=batch-actions-select-all]');
    $selectNone = $container.find('[data-behavior~=batch-actions-select-none]');

    initializeEvents();
    initializeState();
  }

  function initializeEvents() {
    $container.find('[data-behavior~=batch-actions-select]').on('click', toggleCheckboxes);
    $container.find('[data-behavior~=batch-actions-checkbox-container]').on('click', toggleCheckbox);
    $container.find('[data-behavior~=batch-actions-checkbox]').on('change', toggleActions);
    $(document).on('click', '[data-behavior~=batch-actions-action-link]', triggerAction);
  }

  function initializeState() {}

  function setSelectToAll() {
    $selectAll.removeClass('hidden');
    $selectNone.addClass('hidden');
  }

  function setSelectToNone() {
    $selectAll.addClass('hidden');
    $selectNone.removeClass('hidden');
  }

  function checkedCheckboxes() {
    return $container.find('[data-behavior~=batch-actions-checkbox]:checked').map(function() {
      return this.id.match(/\d+/);
    }).toArray().join(',');
  }

  function toggleCheckbox(e) {
    if (this == e.target) {
      $(this).find('[data-behavior~=batch-actions-checkbox]').click();
    }
  }

  function toggleCheckboxes(e) {
    e.preventDefault();

    if (checkedCheckboxes().length > 0) {
      $container.find('[data-behavior~=batch-actions-checkbox]').prop('checked', false).trigger('change');
      setSelectToAll();
    } else {
      $container.find('[data-behavior~=batch-actions-checkbox]').prop('checked', true).trigger('change');
      setSelectToNone();
    }
  }

  function toggleActions() {
    if (checkedCheckboxes().length) {
      $('[data-behavior~=batch-actions-action-link]').removeClass('hidden');
      setSelectToNone();
    } else {
      $('[data-behavior~=batch-actions-action-link]').addClass('hidden');
      setSelectToAll();
    }
  }

  function triggerAction(e) {
    e.preventDefault();

    var action = $(this).attr('href') + '/' + checkedCheckboxes();
    var batchAction = $(this).data('value');
    var csrfToken = $('meta[name="csrf-token"]').attr('content');

    var $form = $('<form>', { method: 'post', action: action });
    $form.append($('<input>', { type: 'hidden', name: '_method', value: 'patch' }));
    $form.append($('<input>', { type: 'hidden', name: 'batch_action', value: batchAction }));
    if (csrfToken) {
      $form.append($('<input>', { type: 'hidden', name: 'authenticity_token', value: csrfToken }));
    }
    $('body').append($form);
    $form.submit();
  }

  return {
    initialize: initialize
  };
})();

$(function() {
  Godmin.BatchActions.initialize();
});
