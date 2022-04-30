import unittest
import JaneStreetDecember

class TestSimulation(unittest.TestCase):

    def test_1(self):
        s = 1
        res = JaneStreetDecember.game(JaneStreetDecember.Config(1, ['Aron', 'Barron', 'Caren', 'Darrin'], 'Aron'))
        self.assertEqual(res, s)

    def test_2(self):
        s = 1
        res = JaneStreetDecember.game(JaneStreetDecember.Config(2, ['Aron', 'Barron', 'Caren', 'Darrin'], 'Barron'))
        self.assertEqual(res, s)

    def test_3(self):
        s = 0.5
        res = JaneStreetDecember.game(JaneStreetDecember.Config(3, ['Aron', 'Caren', 'Darrin'], 'Caren'))
        self.assertEqual(res, s)
    
    def test_3(self):
        s = 0.25
        res = JaneStreetDecember.game(JaneStreetDecember.Config(4, ['Aron', 'Caren', 'Darrin'], 'Darrin'))
        self.assertEqual(res, s)
    
    def test_4(self):
        s = 0.5
        res = JaneStreetDecember.game(JaneStreetDecember.Config(3, ['Aron', 'Barron', 'Caren', 'Darrin'], 'Caren'))
        self.assertEqual(res, s)

    def test_5(self):
        s = 0.25
        res = JaneStreetDecember.game(JaneStreetDecember.Config(4, ['Aron', 'Darrin'], 'Darrin'))
        self.assertEqual(res, s)

    def test_6(self):
        s = 0
        res = JaneStreetDecember.game(JaneStreetDecember.Config(3, ['Aron', 'Barron'], 'Caren'))
        self.assertEqual(res, s)

    def test_7(self):
        res = JaneStreetDecember.game(JaneStreetDecember.Config(5, ['Aron', 'Darrin'], 'Aron'))
        prev = JaneStreetDecember.game(JaneStreetDecember.Config(4, ['Aron', 'Darrin'], 'Darrin'))
        self.assertEqual(res, prev * 0.5)

    def test_8(self):
        s = 0.25 / 3
        res = JaneStreetDecember.game(JaneStreetDecember.Config(6, ['Darrin'], 'Darrin'))
        self.assertEqual(res, s)

    def test_9(self):
        s = 4 / 27
        res = JaneStreetDecember.game(JaneStreetDecember.Config(6, ['Barron'], 'Barron'))
        self.assertEqual(res, s)

    def test_10(self):
        s = 1 / 6
        res = JaneStreetDecember.game(JaneStreetDecember.Config(5, ['Aron', 'Caren'], 'Aron'))
        self.assertEqual(res, s)

    def test_11(self):
        s = 1 / 9
        res = JaneStreetDecember.game(JaneStreetDecember.Config(6, ['Caren'], 'Caren'))
        self.assertEqual(res, s)

    def test_12(self):
        s = 1 / 9 * 1 / 3
        res = JaneStreetDecember.game(JaneStreetDecember.Config(7, ['Caren'], 'Caren'))
        self.assertEqual(res, s)
    
    def test_solution(self):
        s = 0.12
        tot = 0
        for r in range(5, 15):
            tot += JaneStreetDecember.game(JaneStreetDecember.Config(r, ['Darrin'], 'Darrin')) - \
                JaneStreetDecember.game(JaneStreetDecember.Config(r - 1, ['Darrin'], 'Darrin')) / (r - 4)
        self.assertEqual(tot, s)

if __name__ == '__main__':
    unittest.main()