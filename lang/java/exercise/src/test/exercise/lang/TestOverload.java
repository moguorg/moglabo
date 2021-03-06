package test.exercise.lang;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import org.junit.Test;
import static org.junit.Assert.*;

public class TestOverload {

    @Test
    /**
     * 参考：
     * 「Effective Java」項目41
     */
    public void コレクションから特定の要素を削除する() {
        Set<Integer> s = new TreeSet<>();
        List<Integer> l = new ArrayList<>();

        for (int i = -3; i < 3; i++) {
            s.add(i);
            l.add(i);
        }
        
        for(int i = 0; i < 3; i++) {
            s.remove(i);
            /**
             * List.remove(int)の引数は削除対象要素のインデックスである。
             * List.remove(int)で削除された要素はリストから取り除かれるので
             * リストのサイズは小さくなる。そのリストに対し引き続き要素の削除が
             * 行われるため，リストに残る要素は飛び飛びになる。
             */
            //l.remove(i);
            /**
             * List.remove(Object)を実行すれば引数の要素がリストから探し出されて
             * 削除される。
             */
            l.remove(Integer.valueOf(i));
        }

        System.out.println(s);
        System.out.println(l);
        
        assertArrayEquals(s.toArray(), l.toArray());
    }

}
