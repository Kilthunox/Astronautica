<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.9" tiledversion="1.9.2" name="prototype" tilewidth="32" tileheight="32" tilecount="7" columns="7">
 <editorsettings>
  <export target="prototype_tileset.tileset" format="isometric-toolset-tileset"/>
 </editorsettings>
 <properties>
  <property name="source" value="prototype_tilemap_1x7_32x32.png"/>
 </properties>
 <image source="planet_tileset.png" width="224" height="32"/>
 <tile id="0" class="empty">
  <objectgroup draworder="index" id="2">
   <object id="2" class="origin" x="15.5" y="24.625">
    <point/>
   </object>
   <object id="5" class="collision" x="0.875" y="7.75">
    <polygon points="0,0 15,-7.625 30.125,-0.125 30.25,16.125 15.25,23.75 -0.375,16.25"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="1">
  <objectgroup draworder="index" id="2">
   <object id="1" class="origin" x="15.625" y="17.875">
    <point/>
   </object>
  </objectgroup>
 </tile>
 <tile id="2">
  <objectgroup draworder="index" id="2">
   <object id="1" class="origin" x="16.5" y="16.5">
    <point/>
   </object>
   <object id="2" class="collision" x="1" y="24.25">
    <polygon points="0,0 6.875,3.375 22.75,-4 16.5,-8.25"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="3">
  <objectgroup draworder="index" id="2">
   <object id="1" class="origin" x="24.25" y="20">
    <point/>
   </object>
   <object id="2" class="collision" x="9.25" y="27.5">
    <polygon points="0,0 6.875,3.375 22.75,-4 16.5,-8.25"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="4">
  <objectgroup draworder="index" id="2">
   <object id="1" class="origin" x="16.125" y="16.25">
    <point/>
   </object>
   <object id="3" class="collision" x="8.625" y="19.25">
    <polygon points="0,0 7.125,-4.5 22.75,4.125 16.125,8.375"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="5">
  <objectgroup draworder="index" id="2">
   <object id="1" class="origin" x="8" y="19.5">
    <point/>
   </object>
   <object id="2" class="collision" x="0" y="23.125">
    <polygon points="0,0 15.5,8.125 23,4.875 7.875,-3.875"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="6">
  <objectgroup draworder="index" id="2">
   <object id="1" class="origin" x="15.875" y="15.125">
    <point/>
   </object>
   <object id="2" class="collision" x="0.625" y="24.125">
    <polygon points="0,0 15,7.125 30.5,-0.25 15.25,-10"/>
   </object>
  </objectgroup>
 </tile>
</tileset>
