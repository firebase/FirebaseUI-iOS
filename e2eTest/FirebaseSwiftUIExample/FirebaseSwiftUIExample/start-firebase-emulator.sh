#!/bin/bash
if ! [ -x "$(command -v firebase)" ]; then
  echo "❌ Firebase tools CLI is missing."
  exit 1
fi

if ! [ -x "$(command -v node)" ]; then
  echo "❌ Node.js is missing."
  exit 1
fi

if ! [ -x "$(command -v npm)" ]; then
  echo "❌ NPM is missing."
  exit 1
fi

EMU_START_COMMAND="firebase emulators:start --only auth --project flutterfire-e2e-tests --debug"

MAX_RETRIES=3
MAX_CHECKATTEMPTS=60
CHECKATTEMPTS_WAIT=1

RETRIES=1
while [ $RETRIES -le $MAX_RETRIES ]; do

  if [[ -z "${CI}" ]]; then
    echo "Starting Firebase Emulator in foreground."
    $EMU_START_COMMAND
    exit 0
  else
    echo "Starting Firebase Emulator in background."
    $EMU_START_COMMAND &
    CHECKATTEMPTS=1
    while [ $CHECKATTEMPTS -le $MAX_CHECKATTEMPTS ]; do
      sleep $CHECKATTEMPTS_WAIT
      if curl --output /dev/null --silent --fail http://localhost:9099; then
        # Check again since it can exit before the emulator is ready.
        sleep 15
        if curl --output /dev/null --silent --fail http://localhost:9099; then
          echo "Firebase Emulator is online!"
          exit 0
        else
          echo "❌ Firebase Emulator exited after startup."
          exit 1
        fi
      fi
      echo "Waiting for Firebase Emulator to come online, check $CHECKATTEMPTS of $MAX_CHECKATTEMPTS..."
      ((CHECKATTEMPTS = CHECKATTEMPTS + 1))
    done
  fi

  echo "Firebase Emulator did not come online in $MAX_CHECKATTEMPTS checks. Try $RETRIES of $MAX_RETRIES."
  ((RETRIES = RETRIES + 1))

done
echo "Firebase Emulator did not come online after $MAX_RETRIES attempts."
exit 1