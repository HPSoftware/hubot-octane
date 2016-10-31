var fs=require('fs');
fs.createReadStream('./script/default.json').pipe(fs.createWriteStream('../octane/routes/default.json'));
