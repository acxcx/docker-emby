#!/bin/sh

chmod +x /patch/ilasm
chmod +x /patch/ildasm
mkdir /patch/tmp && cd /patch/tmp

#Patch web client
/patch/ildasm /app/emby/Emby.Web.dll -out=Emby.Web.dll
sed -i 's/mb3admin.com/tsumo.cf/g' Emby.Web.dashboard_ui.modules.emby_apiclient.connectionmanager.js
/patch/ilasm -dll Emby.Web.dll -out=/app/emby/Emby.Web.dll
rm Emby.Web.*

#sed -i 's/mb3admin.com/tsumo.cf/g' /app/emby/dashboard-ui/embypremiere/embypremiere.js

# Patch internal
#/patch/ildasm /app/emby/Emby.Server.Implementations.dll -out=Emby.Server.Implementations.dll
#sed -i 's/\/mb3admin.com/\/tsumo.cf/g' Emby.Server.Implementations.dll
#/patch/ilasm -dll Emby.Server.Implementations.dll -out=/app/emby/Emby.Server.Implementations.dll

# Delete tmp
cd ../ && rm -rf tmp
