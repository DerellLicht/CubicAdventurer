copy *.exe CHANGELOG.md README.md portable 
cd portable 
del *.zip 
zip -r CubicAdventurer.portable.zip * 
cd ..
