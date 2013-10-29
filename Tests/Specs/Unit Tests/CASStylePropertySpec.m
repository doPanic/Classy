//
//  CASStylePropertySpec.m
//  Classy
//
//  Created by Jonas Budelmann on 16/10/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CASStyleProperty.h"

SpecBegin(CASStyleProperty)

- (void)testNotParseZeroUnits {
    NSArray *valueTokens = (@[
        [CASToken tokenOfType:CASTokenTypeRef value:@3],
    ]);

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];

    __block CGSize size = CGSizeZero;
    expect([prop transformValuesToCGSize:&size]).to.beFalsy();
    expect(size).to.equal(CGSizeZero);

    __block UIEdgeInsets insets = UIEdgeInsetsZero;
    expect([prop transformValuesToUIEdgeInsets:&insets]).to.beFalsy();
    expect(insets).to.equal(UIEdgeInsetsZero);
}


- (void)testParseOneUnit {
    NSArray *valueTokens = (@[
        [CASToken tokenOfType:CASTokenTypeUnit value:@3],
    ]);

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];

    __block CGSize size = CGSizeZero;
    expect([prop transformValuesToCGSize:&size]).to.beTruthy();
    expect(size).to.equal(CGSizeMake(3, 3));

    __block UIEdgeInsets insets = UIEdgeInsetsZero;
    expect([prop transformValuesToUIEdgeInsets:&insets]).to.beTruthy();
    expect(insets).to.equal(UIEdgeInsetsMake(3, 3, 3, 3));
}

- (void)testParseTwoUnits {
    NSArray *valueTokens = (@[
        [CASToken tokenOfType:CASTokenTypeUnit value:@3],
        [CASToken tokenOfType:CASTokenTypeUnit value:@34],
    ]);

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];

    __block CGSize size = CGSizeZero;
    expect([prop transformValuesToCGSize:&size]).to.beTruthy();
    expect(size).to.equal(CGSizeMake(3, 34));

    __block UIEdgeInsets insets = UIEdgeInsetsZero;
    expect([prop transformValuesToUIEdgeInsets:&insets]).to.beTruthy();
    expect(insets).to.equal(UIEdgeInsetsMake(34, 3, 34, 3));
}

- (void)testResolveSimpleExpression {
    NSArray *valueTokens = (@[
        [CASToken tokenOfType:CASTokenTypeUnit value:@3],
        [CASToken tokenOfType:CASTokenTypeOperator value:@"*"],
        [CASToken tokenOfType:CASTokenTypeUnit value:@2],
        [CASToken tokenOfType:CASTokenTypeOperator value:@"+"],
        [CASToken tokenOfType:CASTokenTypeUnit value:@5],
    ]);

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"3*2+5");
    [prop resolveExpressions];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"11");
}

- (void)testResolveExpressionWithFunction {
    NSArray *valueTokens = (@[
        [CASToken tokenOfType:CASTokenTypeRef value:@"floor"],
        [CASToken tokenOfType:CASTokenTypeSpace value:@"  "],
        [CASToken tokenOfType:CASTokenTypeLeftRoundBrace value:@"("],
        [CASToken tokenOfType:CASTokenTypeUnit value:@4.5],
        [CASToken tokenOfType:CASTokenTypeRightRoundBrace value:@")"],
        [CASToken tokenOfType:CASTokenTypeOperator value:@"*"],
        [CASToken tokenOfType:CASTokenTypeSpace value:@" "],
        [CASToken tokenOfType:CASTokenTypeUnit value:@2],
        [CASToken tokenOfType:CASTokenTypeSpace value:@" "],
        [CASToken tokenOfType:CASTokenTypeOperator value:@"+"],
        [CASToken tokenOfType:CASTokenTypeUnit value:@5],
    ]);

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"floor  (4.5)* 2 +5");
    [prop resolveExpressions];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"13");
}

- (void)testResolveTwoTuple {
    NSArray *valueTokens = (@[
        [CASToken tokenOfType:CASTokenTypeLeftRoundBrace value:@"("],
        [CASToken tokenOfType:CASTokenTypeUnit value:@4.5],
        [CASToken tokenOfType:CASTokenTypeOperator value:@","],
        [CASToken tokenOfType:CASTokenTypeUnit value:@2],
        [CASToken tokenOfType:CASTokenTypeRightRoundBrace value:@")"],
        [CASToken tokenOfType:CASTokenTypeOperator value:@"*"],
        [CASToken tokenOfType:CASTokenTypeUnit value:@5],
    ]);

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"(4.5,2)*5");
    [prop resolveExpressions];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"(22.5,10)");
}

- (void)testResolveTwoTupleForwards {
    NSArray *valueTokens = (@[
        [CASToken tokenOfType:CASTokenTypeUnit value:@5],
        [CASToken tokenOfType:CASTokenTypeOperator value:@"*"],
        [CASToken tokenOfType:CASTokenTypeLeftRoundBrace value:@"("],
        [CASToken tokenOfType:CASTokenTypeUnit value:@4.5],
        [CASToken tokenOfType:CASTokenTypeOperator value:@","],
        [CASToken tokenOfType:CASTokenTypeUnit value:@2],
        [CASToken tokenOfType:CASTokenTypeRightRoundBrace value:@")"],
    ]);

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"5*(4.5,2)");
    [prop resolveExpressions];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"(22.5,10)");
}

- (void)testResolveQuadTuple {
    NSArray *valueTokens = (@[
        [CASToken tokenOfType:CASTokenTypeLeftRoundBrace value:@"("],
        [CASToken tokenOfType:CASTokenTypeSpace value:@" "],
        [CASToken tokenOfType:CASTokenTypeUnit value:@6],
        [CASToken tokenOfType:CASTokenTypeOperator value:@","],
        [CASToken tokenOfType:CASTokenTypeSpace value:@" "],
        [CASToken tokenOfType:CASTokenTypeUnit value:@10],
        [CASToken tokenOfType:CASTokenTypeSpace value:@" "],
        [CASToken tokenOfType:CASTokenTypeUnit value:@12],
        [CASToken tokenOfType:CASTokenTypeOperator value:@","],
        [CASToken tokenOfType:CASTokenTypeSpace value:@" "],
        [CASToken tokenOfType:CASTokenTypeUnit value:@8],
        [CASToken tokenOfType:CASTokenTypeSpace value:@" "],
        [CASToken tokenOfType:CASTokenTypeRightRoundBrace value:@")"],
        [CASToken tokenOfType:CASTokenTypeOperator value:@" / "],
        [CASToken tokenOfType:CASTokenTypeUnit value:@2],
    ]);

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"( 6, 10 12, 8 ) / 2");
    [prop resolveExpressions];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"(3,5,6,4)");
}

- (void)testSolveMixedExpression {
    NSArray *valueTokens = (@[
        [CASToken tokenOfType:CASTokenTypeRef value:@"tiger"],
        [CASToken tokenOfType:CASTokenTypeSpace value:@" "],
        [CASToken tokenOfType:CASTokenTypeSelector value:@"place"],
        [CASToken tokenOfType:CASTokenTypeSpace value:@" "],
        [CASToken tokenOfType:CASTokenTypeUnit value:@2],
        [CASToken tokenOfType:CASTokenTypeSpace value:@" "],
        [CASToken tokenOfType:CASTokenTypeOperator value:@"+"],
        [CASToken tokenOfType:CASTokenTypeSpace value:@" "],
        [CASToken tokenOfType:CASTokenTypeUnit value:@2],
        [CASToken tokenOfType:CASTokenTypeSpace value:@" "],
        [CASToken tokenOfType:CASTokenTypeLeftRoundBrace value:@"("],
        [CASToken tokenOfType:CASTokenTypeUnit value:@1],
        [CASToken tokenOfType:CASTokenTypeSpace value:@" "],
        [CASToken tokenOfType:CASTokenTypeOperator value:@"+"],
        [CASToken tokenOfType:CASTokenTypeSpace value:@" "],
        [CASToken tokenOfType:CASTokenTypeLeftRoundBrace value:@"("],
        [CASToken tokenOfType:CASTokenTypeUnit value:@2],
        [CASToken tokenOfType:CASTokenTypeSpace value:@" "],
        [CASToken tokenOfType:CASTokenTypeOperator value:@"*"],
        [CASToken tokenOfType:CASTokenTypeSpace value:@" "],
        [CASToken tokenOfType:CASTokenTypeUnit value:@3],
        [CASToken tokenOfType:CASTokenTypeRightRoundBrace value:@")"],
        [CASToken tokenOfType:CASTokenTypeSpace value:@" "],
        [CASToken tokenOfType:CASTokenTypeUnit value:@3],
        [CASToken tokenOfType:CASTokenTypeSpace value:@" "],
        [CASToken tokenOfType:CASTokenTypeOperator value:@"+"],
        [CASToken tokenOfType:CASTokenTypeSpace value:@" "],
        [CASToken tokenOfType:CASTokenTypeUnit value:@0.5],
        [CASToken tokenOfType:CASTokenTypeRightRoundBrace value:@")"],
        [CASToken tokenOfType:CASTokenTypeOperator value:@" *"],
        [CASToken tokenOfType:CASTokenTypeSpace value:@" "],
        [CASToken tokenOfType:CASTokenTypeUnit value:@2],
        [CASToken tokenOfType:CASTokenTypeOperator value:@" / "],
        [CASToken tokenOfType:CASTokenTypeUnit value:@5],
    ]);

    CASStyleProperty *prop = [[CASStyleProperty alloc] initWithNameToken:nil valueTokens:valueTokens];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"tiger place 2 + 2 (1 + (2 * 3) 3 + 0.5) * 2 / 5");
    [prop resolveExpressions];
    expect([prop.values componentsJoinedByString:@""]).to.equal(@"tiger place 4(2,1.4)");
}

SpecEnd