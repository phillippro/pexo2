#rsync -azP --include='*/' --include='*rv' --include='*R' --include='*astro' --include='*par' --include='*orb' --exclude='*' ./ ffeng@further.dtm.ciw.edu:Documents/projects/pexo
rsync -azP --include='*R' --include='*astro' --include='*par' --include='*orb' --include='*/' --exclude='*' . ffeng@astro.tdli.sjtu.edu.cn:Documents/projects/pexo
