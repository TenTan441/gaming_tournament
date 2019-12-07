# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# ページ読み込みの際に単純にloadでは適用されないためon 'turbolinks:load'と記載する必要がある。
$(window).on 'turbolinks:load', ->
  $(".search_participants").select2({
    width:      'resolve',  # 横幅
    height: 'resolve',
    allowClear: true,  # x で選択したものを削除できる
    color: "black",
    theme: "bootstrap",
    placeholder: '選択してください',
    language: 'ja'
    # 詳細は http://ivaynberg.github.io/select2/#documentation
  })