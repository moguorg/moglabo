#!/usr/bin/python3
# -*- coding: utf-8 -*-

import unittest

import moglabo.pychalle.algebra as ag

class TestIterationMethodTest(unittest.TestCase):
	'''
	Iteration method test class.
	'''
	def test_newton_raphson_by_sqrt(self):
		'''
		Test for newton_raphson method.
		Test by square root.
		'''
		res = ag.newton_raphson(root=2, start=2, repeat=4)
		self.assertEqual(round(res, 7), 1.4142136)

class TestQuadEq(unittest.TestCase):
	'''
	This is quadratic equation test class.
	'''
	def test_quadeq_real_root(self):
		'''
		test a quadratic equation function
		result is real root
		'''
		formula = [1,-2,-3]
		res = ag.quadeq(formula)
		chk = {3,-1}
		
		self.assertEqual(res, chk)

	def test_quadeq_imaginary_root(self):
		'''
		test a quadratic equation function
		result is imaginary root
		but unsupport and should return error.
		'''
		formula = [1,1,1]
		
		self.assertRaises(ValueError, ag.quadeq, formula)
		
	def test_discriminant(self):
		'''
		test for discriminant of quadratic equation function
		'''
		formula1 = [1,-2,-3]
		xnum = ag.discriminant(formula1)
		res1 = xnum > 0
		formula2 = [1,1,1]
		ynum = ag.discriminant(formula2)
		res2 = ynum < 0
		formula3 = [1,-4,4]
		znum = ag.discriminant(formula3)
		res3 = znum == 0
		self.assertEqual(res1, True)
		self.assertEqual(res2, True)
		self.assertEqual(res3, True)
		
class TestSleq(unittest.TestCase):
	formura1 = [[2,-3,-13],[7,5,1]]
	equation1 = [-2,3]

	formura2 = [[1,-1,2,0],[-2,3,-5,1],[1,-1,1,0]]
	equation2 = [1,1,0]
	
	formura2_2 = [[1,5,-4,-1],[1,-5,15,17],[4,9,5,16]]
	equation2_2 = [-3,2,2]
	
	formura3 = [[1,-2,3],[3,-6,9]]
	
	formura4 = [[1,-2,3],[3,-6,10]]
	
	formura5 = [[1,2,-5,4],[2,3,-7,7],[4,-1,7,7]]
	
	formura6 = [[1,2,-5,4],[2,3,-7,7],[4,-1,7,8]]
	
	INDEFINITE = "indefinite"
	IMPOSSIBLE = "impossible"
	
	def test_sleq_eq_2dim(self):
		'''test by 2 dimention'''
		result = ag.sleq(self.formura1)
		self.assertEqual(result, self.equation1)

	def test_sleq_eq_3dim_inverse_matrix_error(self):
		'''test by 3 dimention at inverse matrix error occured.'''
		result = ag.sleq(self.formura2)
		res = map(lambda x: round(x), result)
		self.assertEqual(list(res), self.equation2)
	
	def test_sleq_eq_3dim(self):	
		'''test by 3 dimention'''
		result2 = ag.sleq(self.formura2_2)
		res2 = map(lambda x: round(x), result2)
		self.assertEqual(list(res2), self.equation2_2)

	def check_errormessage(self, func, args, chkmessage):
		'''check returned error message'''
		try:
			func(args)
		except ValueError as ex:
			message = str(ex)
			self.assertEqual(message, chkmessage)

	def test_sleq_eq_2dim_indefinite(self):
		'''test by 2 dimention and indefinite case'''
		self.check_errormessage(ag.sleq, self.formura3, self.INDEFINITE)

	def test_sleq_eq_2dim_inpossible(self):
		'''test by 2 dimantion and impossible case'''
		self.check_errormessage(ag.sleq, self.formura4, self.IMPOSSIBLE)

	def test_sleq_eq_3dim_indefinite(self):
		'''test by 3 dimention and imdefinite case'''
		self.check_errormessage(ag.sleq, self.formura5, self.INDEFINITE)

	def test_sleq_eq_3dim_inpossible(self):
		'''test by 3 dimantion and inpossible case'''
		self.check_errormessage(ag.sleq, self.formura6, self.IMPOSSIBLE)

#	def test_sleq_indefinite_return_formula(self):
#		'''test return formula at indefinite case'''
#		forms = [[1,2,4,0],[2,-3,1,0],[0,1,1,0]]
#		
#		resforms = ut.sleq(forms)
#		
#		chkforms = [[1,0,2,0],[0,1,1,0],[0,0,0,0]]
#		self.assertEqual(resforms, chkforms)

class TestFormula(unittest.TestCase):
	'''
	Test class for formula class.
	'''
	def test_term_add(self):
		'''
		Term class add test.
		'''
		a = ag.Term(2,2)
		b = ag.Term(3,2)
		
		res = a+b
		
		self.assertEqual(res.calc(), 13)

if __name__ == '__main__':
	print(__file__)
	unittest.main()

