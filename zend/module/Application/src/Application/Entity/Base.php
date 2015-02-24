<?php

namespace Application\Entity;

use Doctrine\Common\Collections\ArrayCollection;
use Zend\Filter\Word as Word;
use Doctrine\ORM\Mapping as ORM;

/**
 * Test
 *
 * @ORM\Table(name="test")
 * @ORM\Entity
 */
class Test extends TestBase
{
    /**
     * @var integer
     *
     * @ORM\Column(name="id", type="bigint", nullable=false)
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="SEQUENCE")
     * @ORM\SequenceGenerator(sequenceName="test_seq", allocationSize=1, initialValue=1)
     */
    private $id;



    public function __construct($parameters = null)
    {
        $filter = new Word\UnderscoreToCamelCase();
        if ($parameters) {
            foreach ($parameters as $parameter => $value) {
                $value = ($value == '') ? null : $value;
                $setterFunction = 'set'.ucfirst($filter->filter($parameter));
                if(method_exists($this, $setterFunction)) {
                    $this->$setterFunction($value);
                };
            }
        }
    }


    /**
     * Get id
     *
     * @return integer 
     */
    public function getId()
    {
        return $this->id;
    }

    
}
