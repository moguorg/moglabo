((g => {
    "use strict";
    
    const funcs = [
        () => {
            const base = ".arguments-object-in-arrow-functions ",
                resultArea = g.select(base + ".resultarea"),
                runner = g.select(base + ".check-arguments-object"),
                clearer = g.select(base + ".clear-result");
                
            const getArgumentsLength = () => {
                /**
                 * アロー関数内でもArgumentsオブジェクト自体はECMAScript5までと
                 * 同じように存在している。しかし参照するとエラーになってしまう。
                 * この振る舞いはstrictモードでなくても変わらない。
                 */
                if(arguments){
                    return arguments.length;
                } else {
                    g.log(arguments);
                    throw new Error("Arguments is nothing!");
                }
            }; 
            
            g.clickListener(runner, () => {
                let result;
                try{
                    /**
                     * アロー関数はnew演算子と合わせて呼び出すことができない。
                     */
                    //new getArgumentsLength();
                    result = getArgumentsLength(1, 2, 3, 4, 5);
                }catch(err){
                    result = err.message;
                }
                g.println(resultArea, result);
            });
            
            g.clickListener(clearer, () => {
                g.clear(resultArea);
            });
        },
        () => {
            const base = ".feature-arrow-functions ",
                resultArea = g.select(base + ".resultarea"),
                runner = g.select(base + ".display-result"),
                clearer = g.select(base + ".clear-result");
                
            const featureTests = new Map([
                ["new", () => {
                    const SampleFunc = () => "Hello, world";
                    const obj = new SampleFunc();
                    return obj;
                }],
                ["prototype", () => {
                    /**
                     * prototypeプロパティ自体は存在しない。独自で定義はできるが
                     * アロー関数はnew演算子と合わせて呼び出すことができないので
                     * prototypeプロパティ本来の用途で使われることはない。
                     */
                    const SampleFunc = () => 100;
                    return SampleFunc.prototype;
                }],
                ["duplicateargs", () => {
                    const s = "アロー関数ならstrictモードでなくてもエラー";
                    
                    /**
                     * アロー関数では引数名の重複はstrictモードの有効・無効に関わらず
                     * シンタックスエラーになる。
                     */
                    //const duplicateArgsTest = (a, a) => {
                    //    return a;
                    //};
                    /**
                     * strictモードでなければfunction式における引数名の重複は
                     * エラーにならない。以下の例の場合，第1引数は無視される。
                     */
                    //const duplicateArgsTest = function (a, a) {
                    //    return a;
                    //};
                    //return duplicateArgsTest("", s);
                    
                    return s;
                }]
            ]);
                
            const getSelectedFeatureName = () => {
                const featureEles = g.selectAll(base + ".check-target-features input");
                return g.getSelectedValue(featureEles);
            }; 
            
            g.clickListener(runner, () => {
                try{
                    const featureName = getSelectedFeatureName();
                    const featureTest = featureTests.get(featureName);
                    g.println(resultArea, featureTest());
                }catch(err){
                    g.println(resultArea, err);
                }
            });

            g.clickListener(clearer, () => {
                g.clear(resultArea);
            });
        },
        () => {
            const base = ".tail-call-optimization ",
                resultArea = g.select(base + ".resultarea"),
                runner = g.select(base + ".display-result"),
                clearer = g.select(base + ".clear-result"),
                numEle = g.select(base + ".input-factorial-number");
                
            const factorial = (n, accumulator = 1) => {
                if (n <= 1) {
                    return accumulator;
                } else {
                    return factorial(n - 1, accumulator * n);
                }
            };
            
            g.clickListener(runner, () => {
                const n = parseInt(numEle.value);
                if(g.nump(n)){
                    try {
                        const result = factorial(n);
                        g.println(resultArea, result);
                    } catch(err) {
                        g.println(resultArea, err);
                    }
                }
            });
            
            g.clickListener(clearer, () => {
                g.clear(resultArea);
            });
        }
    ];
    
    g.run(funcs);
})(window.goma));