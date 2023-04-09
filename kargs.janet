# parse, but symbols become strings
# and failures to parse also become strings
(defn- parse*
  [str]
  (if-let [v (parse str)
           _ (not (nil?    v))
           _ (not (symbol? v))]
    v
    str))

(def- flags  |{:type  :flags
               :value (keyword $)})
(def- longeq |{:type  :keyvalue
               :key   (keyword $)
               :value (parse* $1)})
(def- long   |{:type  :key
               :key   (keyword $)})

(def- argparse
  # flags are conveniences, you can just :abcd
  ~{:flags  (/ (* "-" (! "-")        '(some 1)) ,flags)
    :longeq (/ (* "--" '(to "=") "=" '(some 1)) ,longeq)
    :long   (/ (* "--"               '(some 1)) ,long)
    :main (+ :flags :longeq :long)})
(def- argparser (peg/compile argparse))

# -abcd becomes :abcd
# --a b becomes :a janet-parsed-"b"
# --a=b becomes :a janet-parsed-"b"
(defn kargs
  [& args]
  (def out @[])
  (var need false)
  (var continue false)
  (each arg args
    # handle --
    (when (and (= arg "--") (not continue))
      (set continue true))
    (if continue
      # if post -- just add strings
      (array/push out (parse* arg))
      # if parsing arguments
      (if need
        # if we need an argument value, we provide one
        (do (array/push out (parse* arg))
            # we no longer need one
            (toggle need))
        # if we do not need an argument value
        # we try to see if it's a flag
        (do (match (first (peg/match argparser arg))
              # if it's flags, we push the flags
              {:type  :flags
               :value v}       (array/push out v)
              # if it's an option with a value, we push both
              {:type  :keyvalue
               :key   k
               :value v}       (array/insert out -1 k v)
              # if it's an option without a value, we push it
              # and say we expect a value
              {:type  :key
               :key   k}       (do (array/push out k)
                                   (toggle need))
              # otherwise we push the parsed value
              (array/push out (parse* arg)))))))
  out)

# let's say you have a function
(comment (defn i-wish-i-was-main
           [a b &named foo bar & args]))
# you can now call it!
# (defn main [& args] (i-wish-i-was-main ;(kargs ;args)))
# this works even if a starts with "--" while wanting a string, just make sure you add "s": '"--something"'

# convenience macro to wrap a function
(defmacro main
  [f]
  (let [name (gensym)
        args (gensym)]
    ~(defn main
       [,name & ,args]
       (,f ;(,kargs ;,args)))))

# convenience macro to wrap a function, but it also passes name
(defmacro named-main
  [f]
  (let [name (gensym)
        args (gensym)]
    ~(defn main
       [,name & ,args]
       (,f ;(,kargs ,name ;,args)))))
