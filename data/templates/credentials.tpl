User,Access key ID,Secret access key
%{ for name, data in trainers ~}
${name},${data.access},${data.secret}
%{ endfor ~}
%{ for name, data in users ~}
${name},${data.access},${data.secret}
%{ endfor ~}
