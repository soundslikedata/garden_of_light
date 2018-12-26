# garden_of_light

https://www.youtube.com/watch?v=EjbaUwfStAo&feature=youtu.be

Proof of concept showcasing integrations with sonic pi to create light enhanced soundscapes.

Using a transient detection algorithm in sonic pi, data from samples (in this case bird sounds) is sent to wireless lights connected to processing. The main point of note with this demo is that this project does not use FFT to directly visualize the sounds. A problem with FFT based visualization is that when two distict sounds occupy the same frequency range they receive the same visual output. This avoids the problem by mapping individual sample data directly onto the light source.

The open source light hardware used in the demo video can be found here: https://github.com/PWRFLcreative/Spore#installationrun-instructions

The onset detection algorithm was inspired from this: https://in-thread.sonic-pi.net/t/how-to-access-data-from-onset-function-using-lambda/1542/5

The bird sounds were found using google's open source bird sound ai and the Vancouver Soundscape Database. 

