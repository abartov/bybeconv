function is_clamped(elid) {
  const el = document.getElementById(elid);
  return el.scrollHeight > (el.clientHeight + 5);
}
