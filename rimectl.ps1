Param(
  [alias("c")][switch]$Copy,
  [alias("e")][switch]$Erase,
  [alias("u")][switch]$Update,
  [alias("d")][switch]$Deploy,
  [alias("gi")][switch]$Gitignore,
  [alias("pf")][switch]$PrintFiles
)

$weasel_path = "C:\Program Files (x86)\Rime\weasel-0.16.1"
if (-not (Test-Path $weasel_path)) {
  Write-Output "Weasel not found at $weasel_path"
  exit
}

$ime_files_map = [ordered]@{
  "rime-ice" = @(
    "default.yaml",
    "double_pinyin.schema.yaml",
    "melt_eng.dict.yaml",
    "melt_eng.schema.yaml",
    "radical_pinyin.dict.yaml",
    "radical_pinyin.schema.yaml",
    "rime_ice.dict.yaml",
    "rime_ice.schema.yaml",
    "rime.lua",
    "symbols_caps_v.yaml",
    "symbols_v.yaml",
    "weasel.yaml",

    "cn_dicts",
    "en_dicts",
    "lua",
    "opencc"
  );
  "rime-moqi" = @(
    "moqi_zrm.schema.yaml",
    "moqi.yaml",
    "moqi.extended.dict.yaml",

    # moqi_zrm.dict.yaml : .schema.dependencies
    "reverse_moqima.schema.yaml",
    "reverse_moqima.dict.yaml",
    "radical_flypy.schema.yaml",
    "radical_flypy.dict.yaml",
    "zrlf.schema.yaml",
    "zrlf.dict.yaml",
    "emoji.schema.yaml",
    "emoji.dict.yaml",
    "easy_en.schema.yaml",
    "easy_en.dict.yaml",
    "jp_sela.schema.yaml",
    "jp_sela.dict.yaml",
    "moqi_big.schema.yaml",
    "moqi_big.extended.dict.yaml",

    "cn_dicts_common",
    "cn_dicts_moqi",
    "custom_phrase",
    "lua",
    "opencc"
  );
  "rime-lua-aux-code" = @(
    "lua"
  );
  "patch" = @(
    "lua",
    "rime_ice.dict.yaml"
  );
}

if ($Gitignore) {
  $gitignore_template = Get-Content .\.gitignore.template
  $gitignore_content = $gitignore_template
  # foreach ($files in $ime_files_map.Values) {
  #   $gitignore_content += "`n" + (($files) -join "`n")
  # }
  foreach ($f in $ime_files_map.GetEnumerator()) {
    $gitignore_content += "`n# Generated from $($f.Key)"
    foreach ($file in $f.Value) {
      $gitignore_content += "/$file"
    }
  }
  Set-Content -Path .\.gitignore -Value $gitignore_content
  Write-Output "Generated .gitignore"
}

if ($Update) {
  git submodule update --rebase --remote
}

if ($Erase) {
  foreach ($files in $ime_files_map.Values) {
    foreach ($file in $files) {
      if (Test-Path .\$file) {
        Remove-Item -Path .\$file -Recurse -Force
        Write-Output "Removed $file"
      }
    }
  }
}

if ($Copy) {
  foreach ($f in $ime_files_map.GetEnumerator()) {
    foreach ($file in $f.Value) {
      Copy-Item -Path .\$($f.Key)\$file -Destination .\ -Recurse -Force
      Write-Output "Copied $($f.Key)\$file"
    }
  }
}

if ($PrintFiles) {
  foreach ($f in $ime_files_map.GetEnumerator()) {
    foreach ($file in $f.Value) {
      Write-Output ".\$($f.Key)\$file"
    }
  }
}

if ($Deploy) {
  & "$weasel_path\WeaselDeployer.exe" /deploy
}
