function tournament_type() {
  radio = document.getElementsByName('tournament[group_stage_enabled]') 
  if(radio[0].checked) {
    document.getElementById('normal-tournament').style.display = "";
    document.getElementById('two-stage-tournament').style.display = "none";
  } else if(radio[1].checked) {
    document.getElementById('normal-tournament').style.display = "none";
    document.getElementById('two-stage-tournament').style.display = "";
  }
}

//オンロードさせ、リロード時に選択を保持
window.onload = tournament_type;
