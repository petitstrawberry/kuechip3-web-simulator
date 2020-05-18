function copy(text) {
  let elmTmpDiv = document.createElement('div');
  elmTmpDiv.appendChild(document.createElement('pre')).textContent = text;

  let style = elmTmpDiv.style;
  style.position = 'fixed';
  style.left = '-100%';

  document.body.appendChild(elmTmpDiv);
  document.getSelection().selectAllChildren(elmTmpDiv);

  let result = document.execCommand('copy');

  document.body.removeChild(elmTmpDiv);
}


function closeOverlay() {
  $('.fullscreen-overlay').hide()
}


/* ---------- 各種リスナ ---------- */
// アセンブラをオーバーレイ表示
$('#btn-open-assembler').on('click', () => {
  $('#overlay-assembler').show()
})

// 全オーバーレイの非表示
$('.btn-close-overlay-wrapper').on('click', closeOverlay)

// 各種キーイベント
$(window).on('keyup', e => {
  console.log(e.key)

  // Esc で全オーバーレイを閉じる
  if ( e.keyCode === 27 ) {
    closeOverlay()
  }
})

// クリップボードにコピー
$('#btn-copy-to-clipboard').on('click', () => {
  logger.info('Copy binary to clipboard')
  copy( $('#output-binary').val() )
})

// シミュレータにコピー
$('#btn-copy-to-simulator').on('click', () => {
  logger.info('Copy binary to simulator input')
  const binary = $('#output-binary').val()
  $('#inst').val(binary)

  closeOverlay()
})
