from pexopy import Pexo

pexo_output = Pexo().run(
    mode="emulate",
    component="TAR",
    time= "../pexo/input/gaia80yrby10day.tim",
    par="../pexo/input/ACAgaia.par"
)

print(type(pexo_output))
print(pexo_output.dtype.names)
print(pexo_output)
