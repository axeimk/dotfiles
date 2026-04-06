#!/bin/bash
# 音声通知：Windowsのシステム音を再生
powershell.exe -c "(New-Object Media.SoundPlayer 'C:\\Windows\\Media\\CCNotify.wav').PlaySync()"