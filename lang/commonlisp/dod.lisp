;;;dod.lisp
;;;参考:LandOfLisp 15章
;;;

;プレイヤーの総数
(defparameter *num-players* 2)
;マスに積むサイコロの最大数
(defparameter *max-dice* 3)
;ゲーム盤のサイズ
(defparameter *board-size* 2)
;ゲーム盤のマスの数
(defparameter *board-hexnum* (* *board-size* *board-size*))

(defun board-array (lst)
  ;リストで表されたゲーム盤を配列に変える。
  (make-array *board-hexnum* :initial-contents lst))

(defun gen-board ()
  ;ランダムな値を割り振ったゲーム版を生成する。
  (board-array (loop for n below *board-hexnum* 
					 collect (list (random *num-players*)
								   (1+ (random *max-dice*))))))

(defun player-letter (n) 
  ;プレイヤー番号をプレイヤー名に変換する。
  (code-char (+ 97 n)))

(defun draw-board (board)
  ;ゲーム盤を見やすい書式で表示する。
  (loop for y below *board-size* 
		do (progn (fresh-line) 
				  (loop repeat (- *board-size* y)
						do (princ " "))
				  (loop for x below *board-size* 
						for hex = (aref board (+ x (* *board-size* y)))
						do (format t "~a-~a " (player-letter (first hex))
								   (second hex))))))

(defun game-tree (board player spare-dice first-move)
  ;ゲーム盤の状態と現在のプレイヤーを保持した木構造を作成する。
  (list player
		board
		(add-passing-move board
						  player
						  spare-dice
						  first-move
						  (attacking-moves board player spare-dice))))

(defun add-passing-move (board player spare-dice first-move moves)
  ;ゲームの木構造に相手に手番を渡す指し手を加える。
  (if first-move
	moves
	(cons (list nil
				(game-tree (add-new-dice board player (1- spare-dice))
						   (mod (1+ player) *num-players*)
						   0
						   t))
		  moves)))

(defun attacking-moves (board cur-player spare-dice)
  ;攻撃可能なマスを探し，攻撃の指し手をゲーム木に加える。
  (labels ((player (pos)
				   (car (aref board pos)))
		   (dice (pos)
				 (cadr (aref board pos))))
	(mapcan (lambda (src)
			  (when (eq (player src) cur-player)
				(mapcan (lambda (dst)
						  (when (and (not (eq (player dst) cur-player))
									 (> (dice src) (dice dst)))
							(list 
							  (list (list src dst)
									(game-tree (board-attack board cur-player
															 src dst (dice src))
											   cur-player
											   (+ spare-dice (dice dst))
											   nil)))))
						(neighbors src))))
			(loop for n below *board-hexnum*
				  collect n))))

(defun neighbors (pos)
  ;隣接するマスを探す。
  (let ((up (- pos *board-size*))
		(down (+ pos *board-size*)))
	(loop for p in (append (list up down)
						   (unless (zerop (mod pos *board-size*))
							 (list (1- up) (1- pos)))
						   (unless (zerop (mod (1+ pos) *board-size*))
							 (list (1+ pos) (1+ down))))
		  when (and (>= p 0) (< p *board-hexnum*))
		  collect p)))

(defun board-attack (board player src dst dice)
  ;srcマスからdstマスに対して攻撃を行う。
  (board-array (loop for pos from 0
					 for hex across board
					 collect (cond ((eq pos src) (list player 1))
								   ((eq pos dst) (list player (1- dice)))
								   (t hex)))))

(defun add-new-dice (board player spare-dice)
  ;ゲーム盤を走査してサイコロの補給を行う。
  (labels ((f (lst n)
			  (cond ((null lst) nil)
					((zerop n) lst)
					(t (let ((cur-player (caar lst))
							 (cur-dice (cadar lst)))
						 (if (and (eq cur-player player) (< cur-dice *max-dice*))
						   (cons (list cur-player (1+ cur-dice))
								 (f (cdr lst) (1- n)))
						   (cons (car lst) (f (cdr lst) n))))))))
	(board-array (f (coerce board 'list) spare-dice))))

(defun play-vs-human (tree)
  ;2人のプレイヤーでゲームを実行する。
  (print-info tree)
  (if (caddr tree)
	(play-vs-human (handle-human tree))
	(announce-winner (cadr tree))))

(defun print-info (tree)
  ;現在のゲームの状態を出力する。
  (fresh-line)
  (format t "current player = ~a" (player-letter (car tree)))
  (draw-board (cadr tree)))

(defun handle-human (tree)
  ;プレイヤーが選択できる指し手を表示して選択結果を読み込む。
  (fresh-line)
  (princ "choose your move:")
  (let ((moves (caddr tree)))
	(loop for move in moves
		  for n from 1
		  do (let ((action (car move)))
			   (fresh-line)
			   (format t "~a. " n)
			   (if action 
				 (format t "~a -> ~a" (car action) (cadr action))
				 (princ "end turn"))))
	(fresh-line)
	(cadr (nth (1- (read)) moves))))

(defun winners (board)
  ;マスの獲得数を調べてゲームの勝者を返す。
  (let* ((tally (loop for hex across board
					  collect (car hex)))
		 (totals (mapcar (lambda (player)
						   (cons player (count player tally)))
						 (remove-duplicates tally)))
		 (best (apply #'max (mapcar #'cdr totals))))
	(mapcar #'car 
			(remove-if (lambda (x)
						 (not (eq (cdr x) best)))
					   totals))))

(defun announce-winner (board)
  ;ゲームの勝者を表示する。
  (fresh-line)
  (let ((w (winners board)))
	(if (> (length w) 1)
	  (format t "The game is a tie between ~a" (mapcar #'player-letter w))
	  (format t "The winner is ~a" (player-letter (car w))))))












