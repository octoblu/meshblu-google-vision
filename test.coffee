{Client, Feature, Request, Image} = require('vision-cloud-api')

auth = 'AIzaSyCpVBXBUSi-7GW1Ee5SQn-HTqESm-7Ddtk'
feature1 = new (Feature)('FACE_DETECTION')
feature2 = new (Feature)('LOGO_DETECTION')
features = [
  feature1
  feature2
]
url = 'http://www.uni-regensburg.de/Fakultaeten/phil_Fak_II/Psychologie/Psy_II/beautycheck/english/durchschnittsgesichter/m(01-32)_gr.jpg'
image = new Image url: url
request = new Request image: image, features: features
client = new Client auth: auth

client.annotate([ request ]).then((response) ->
  console.log JSON.stringify response
).catch (e) ->
  console.log e
