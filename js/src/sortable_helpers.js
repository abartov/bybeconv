// Helper functions for sortable receive handling
function computeTransplantPositions(ui, destIndex) {
  // ui: object with item (jQuery-like), sender (DOM/jQuery-like)
  // destIndex: zero-based index at destination
  var oldIndexStr = null;
  if (ui && ui.sender && ui.sender[0]) {
    oldIndexStr = ui.sender[0].getAttribute && ui.sender[0].getAttribute('data-previndex');
  }
  if (!oldIndexStr && ui && ui.item && ui.item[0]) {
    oldIndexStr = ui.item[0].getAttribute && ui.item[0].getAttribute('data-previndex');
  }

  var oldIndex = oldIndexStr !== null && oldIndexStr !== undefined ? parseInt(oldIndexStr, 10) : null;
  var old_pos = (oldIndex !== null) ? (oldIndex + 1) : null; // server expects 1-based
  var new_pos = (destIndex !== null && destIndex !== undefined) ? (destIndex + 1) : null;

  return { old_pos: old_pos, new_pos: new_pos };
}

module.exports = { computeTransplantPositions };
