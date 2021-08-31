AWS account ID: ${account}
AWS region: ${region}

User,Password,Access key ID,Secret access key
%{ for name, data in trainers ~}
${name},${data.password},${data.access},${data.secret}
%{ endfor ~}
%{ for name, data in students ~}
${name},${data.password},${data.access},${data.secret}
%{ endfor ~}
