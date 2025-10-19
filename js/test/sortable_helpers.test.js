const { computeTransplantPositions } = require('../src/sortable_helpers');

describe('computeTransplantPositions', () => {
  test('prefers ui.sender data-previndex for old_pos and uses 1-based positions', () => {
    const fakeSender = [{ getAttribute: (name) => { if (name === 'data-previndex') return '2'; return null; } }];
    const fakeItem = [{ getAttribute: (name) => { if (name === 'data-previndex') return '5'; return null; } }];

    const ui = { sender: fakeSender, item: fakeItem };

    // destination index is 0-based (e.g., inserted at index 0)
    const destIndex = 0;

    const res = computeTransplantPositions(ui, destIndex);
    expect(res.old_pos).toBe(3); // sender previndex 2 -> 1-based 3
    expect(res.new_pos).toBe(1); // destIndex 0 -> 1-based 1
  });

  test('falls back to ui.item data-previndex if sender is missing', () => {
    const fakeItem = [{ getAttribute: (name) => { if (name === 'data-previndex') return '4'; return null; } }];
    const ui = { sender: null, item: fakeItem };
    const res = computeTransplantPositions(ui, 2);
    expect(res.old_pos).toBe(5);
    expect(res.new_pos).toBe(3);
  });

  test('returns null for missing values', () => {
    const ui = { sender: null, item: null };
    const res = computeTransplantPositions(ui, null);
    expect(res.old_pos).toBeNull();
    expect(res.new_pos).toBeNull();
  });
});
